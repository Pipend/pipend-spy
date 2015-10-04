{promises:{bindP, from-error-value-callback, new-promise, returnP, to-callback}} = require \async-ls
require! \md5
{MongoClient} = require \mongodb

waitP = (ms) ->
    (res) <- new-promise
    set-timeout do 
        -> res "done"
        ms

# cache of all the existing mongo connections
cache = {}

# String -> MongoConnectionOptions -> p db
connect = (mongo-connection-string, mongo-connection-options) -->
    (MongoClient.connect mongo-connection-string, mongo-connection-options)
        .then (db) ->
            db.connected = true
            db.once \close, -> db.connected = false
            db
        .catch (err) ->
            console.log \mongo-connection-err, err
            <- bindP waitP (mongo-connection-options?.retry-interval ? 5000)
            connect mongo-connection-string, mongo-connection-options

# String -> MongoConnectionOptions -> p Store
module.exports = (mongo-connection-string, mongo-connection-options) -->
    
    db <- bindP do ->

        hash = md5 mongo-connection-string

        # if the db instance is cached and is still connected then simply wrap it in a promise and return
        if !!cache?[hash]?.db and cache[hash].db?.connected
            returnP cache[hash].db

        # otherwise return a promise which establishes a connection to database (and keeps retrying on error)
        else
            
            if !cache?[hash]?.promise
                cache[hash] = cache[hash] ? {}
                    ..promise = do ->
                        db <- bindP (connect mongo-connection-string, mongo-connection-options)
                        cache[hash] <<< {db, promise: undefined}
                        returnP db

            cache[hash].promise

    returnP do

        # insert :: insertInto -> object -> p insertedObject
        insert: ({collection}, object) -->
            {ops} <- bindP (db.collection collection .insert object)
            returnP ops.0
        
        close: (->)