{promises:{bindP, from-error-value-callback, new-promise, returnP, sequenceP, to-callback}} = require \async-ls
{get-ip-from-request, get-country-from-ip} = require \./ip-to-country
{id, map, obj-to-pairs, pairs-to-obj, Str, take} = require \prelude-ls 
require! \ua-parser-js

module.exports = do ->

    # record :: [StorageDetail] -> Event -> p [InsertedEvent]
    record = (storage-details, event-object) -->
    
        creation-date = new Date!
        creation-time = creation-date.get-time!
        
        extended-event-object = {
            creation-date
            creation-time
        } <<< event-object

        storage-details 
            |> map ({name, connection-string, connection-options, insert-into}) ->

                # establish a connection to the store
                {insert, close} <- bindP ((require "./stores/#{name}") connection-string, connection-options)

                # insert extended-event-object into the store
                result <- bindP insert insert-into, extended-event-object

                # close the connection to the store & return the inserted event
                close!
                returnP result

            |> sequenceP

    # record-req :: [StorageDetail] -> Request -> Event -> p ExtendedEvent
    record-req = (storage-details, {headers, original-url, protocol}:req, event-object) -->

        # get ip & country from event-object (if present) otherwise use IP2Location
        ip = event-object?.ip ? (get-ip-from-request req)
        country = event-object?.country ? (get-country-from-ip ip)
        
        # get the url from req, cut data urls (as mongo has issues inserting big & complex ones)
        url = "#{protocol}://#{req.get \host}#{original-url}"
        url :=
            | (url.trim!.index-of "data:text/html") == 0 => "data:text/html"
            | _ => url

        # tokenize-ip :: String -> Int -> String
        tokenize-ip = (ip, n) -> 
            (ip or '') .split \.
                |> take n 
                |> Str.join \.

        record do 
            storage-details
            {
                ip
                ip-tokens: [2 to 3]
                    |> map -> ["ip#{it}", (tokenize-ip ip, it)]
                    |> pairs-to-obj
                country
                headers
                ua-tokens: ua-parser-js (req.headers[\user-agent] or "")
                url
                query-tokens: (require \querystring) .parse ((require \url) .parse url .query)
                    |> obj-to-pairs
                    |> map ([key, value])->
                        key .= replace \., \_
                        value-parser =
                            | (/^\d+$/g.test value) => parse-int
                            | (/^(\d|\.)+$/g.test value) => parse-float
                            | value == \true => -> true
                            | value == \false => -> false
                            | value == '' => -> undefined
                            | _ => id
                        [key, if key == \eventArgs then {} else value-parser value]
                    |> pairs-to-obj
            } <<< event-object

    {record, record-req}
    
