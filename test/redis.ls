assert = require \assert
{promises:{bindP, from-error-value-callback, new-promise, returnP, to-callback}} = require \async-ls
require! \redis
redis-store = require \../stores/redis

describe \redis, ->

    # test database
    connection-string = \redis://localhost:6379/
    connection-options = {}
    channel = \events

    specify "must return a p Store with insert & close methods", ->
        {insert, close}:result <- bindP (redis-store connection-string, connection-options)
        return (new-promise (, rej) -> rej "must provide insert method") if !insert
        return (new-promise (, rej) -> rej "must provide close method") if !close
        
        returnP result

    specify "must publish object to specified channel", ->
        
        published-event-type = ""

        redis-client = redis.create-client 6379, \127.0.0.1, {}
            ..once \connect, ->
                redis-client.subscribe \events
                redis-client.on \message, (, message) ->
                    published-event-type := (JSON.parse message).event-type

        # connect to the store and insert an event object
        {insert} <- bindP (redis-store connection-string, connection-options)
        published-object <- bindP insert {channel}, {event-type: \test}
        if (JSON.parse published-object).event-type != \test
            new-promise (, rej) -> rej "expected published-object.event-type to be test"
        if published-event-type != \test
            new-promise (, rej) -> rej "expected published event-type to be test instead of #{published-event-type}"
        returnP published-object
            
