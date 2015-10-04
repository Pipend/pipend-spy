{promises:{bindP, from-error-value-callback, new-promise, returnP, to-callback}} = require \async-ls
require! \md5
{concat-map, id, obj-to-pairs} = require \prelude-ls
require! \redis

# :: String -> RedisConnectionOptions -> p Store
module.exports = (connection-string, connection-options) -->

    # maintain a cache of all the open redis-connections 
    # instead of repeatedly connecting which can cause EMFILE exception
    # Map String, RedisConnection
    cache = {}

    if !!cache[connection-string]
        returnP cache[connection-string]

    else

        # parse connection string
        [, host, port, database]? = /redis:\/\/(.*?):(.*?)\/(\d+)?/g.exec connection-string

        res, rej <- new-promise
        redis-client = redis.create-client port, host, connection-options
            ..once \connect, ->

                # select the give database
                err <- do -> (callback) -> if !!database then redis-client.select database, callback else callback null
                return rej err if !!err

                # update the cache before returning the store
                res do 
                    cache[connection-string] = 

                        # insert :: insertInto -> object -> p insertedObject
                        insert: ({channel}?, event) -->
                            if !!channel
                                redis-client.publish channel, JSON.stringify event
                        
                        # close :: a -> Void
                        close: (->)

            ..once \error, (err) -> rej err