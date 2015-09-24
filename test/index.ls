assert = require \assert
{promises:{bindP, from-error-value-callback, new-promise, returnP, sequenceP, to-callback}} = require \async-ls
spy = require \../index
{MongoClient} = require \mongodb
{map} = require \prelude-ls

describe "stores", ->
    require \./mongo

require \./ip-to-country

describe "index.ls", ->

    default-mongo-storage-details = 
        name: \mongo
        connection-string: \mongodb://localhost:27017/test
        connection-options: {}

    storage-details = 
        * {} <<< default-mongo-storage-details <<< {insert-into: {collection: \events}}
        * {} <<< default-mongo-storage-details <<< {insert-into: {collection: \temp}}

    # [Event] -> p [Event]
    validate-inserted-events = (inserted-events) ->
        if inserted-events.length != storage-details.length
            new-promise (, rej) -> rej "inserted-event.length must be #{storage-details.length} instead of #{inserted-events.length}"

        else
            [0 til storage-details.length]  
                |> map (index) ->
                    {name, connection-string, connection-options, insert-into} = storage-details[index]
                    inserted-event = inserted-events[index]
                    match name
                        | \mongo =>
                            return (new-promise (, rej) -> rej "inserted-event.creation-time must be defined") if !inserted-event.creation-time
                            return (new-promise (, rej) -> rej "inserted-event.event-type must be test instead of #{inserted-event.event-type}") if inserted-event.event-type != \test
                            db <- bindP (MongoClient.connect connection-string, connection-options)
                            result <- bindP (db.collection insert-into.collection .find-one {creation-time: inserted-event.creation-time})
                            return (new-promise (, rej) -> rej "unable to find a record with creation-time of #{inserted-event.creation-time}") if !result
                            <- bindP (db.collection insert-into.collection .remove {creation-time: inserted-event.creation-time})
                            returnP inserted-event
                        | _ => new-promise (, rej) -> rej "unknown store: #{name}"
                |> sequenceP

    specify "must record event", ->
        inserted-events <- bindP (spy storage-details).record {event-type: \test}
        validate-inserted-events inserted-events

    specify "must record event with request", ->

        # req mockup
        req =
            get: -> ''
            socket:
                remote-address: \127.0.0.1
            headers:
                user-agent: \test
            original-url: \localhost
            protocol: \http://

        inserted-events <- bindP (spy storage-details).record-req req, {event-type: \test}

        # validate if the events were indeed inserted into the database
        <- bindP (validate-inserted-events inserted-events)

        # validate if the events have the expected properties
        inserted-events
            |> map (inserted-event) ->
                return (new-promise (, rej) -> rej "inserted-event.ip must be #{req.socket.remote-address} instead of #{inserted-event.ip}") if inserted-event.ip != req.socket.remote-address                
                returnP inserted-event
            |> sequenceP

