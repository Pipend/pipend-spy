assert = require \assert
{promises:{bindP, from-error-value-callback, new-promise, returnP, to-callback}} = require \async-ls
{record, record-req} = require \../index
{MongoClient} = require \mongodb
mongo = require \../stores/mongo

describe "mongo", ->

    # test database
    connection-string = \mongodb://localhost:27017/test
    connection-options = {}
    collection = \events

    specify "must return a p Store with insert & close methods", ->
        {insert, close}:result <- bindP (mongo connection-string, connection-options)
        return (new-promise (, rej) -> rej "must provide insert method") if !insert
        return (new-promise (, rej) -> rej "must provide close method") if !close
        
        returnP result

    specify "must insert object into specified database/collection", ->

        # connect to the store and insert an event object
        {insert} <- bindP (mongo connection-string, connection-options)
        inserted-event <- bindP insert {collection}, {event-type: \test}
        return (new-promise (, rej) -> rej "inserted-event._id must be defined") if !inserted-event._id
        return (new-promise (, rej) -> rej "event-type must be = test instead of #{inserted-event.event-type}") if inserted-event?.event-type != \test

        # connect to the test database
        db <- bindP (MongoClient.connect connection-string, connection-options)

        # remove the inserted event (unit test must avoid pollution of database)
        result <- bindP (db.collection collection .find-one {_id: inserted-event._id})

        # if found return the inserted event
        if !!result 
            <- bindP (db.collection collection .remove {_id: inserted-event._id})
            returnP inserted-event 
        else 
            new-promise (, rej) -> rej "unable to find a record with _id = #{inserted-event._id}"
        
