[![Build Status](https://travis-ci.org/Pipend/pipend-spy.svg?branch=master)](https://travis-ci.org/Pipend/pipend-spy)    [![Coverage Status](https://coveralls.io/repos/Pipend/pipend-spy/badge.svg?branch=master&service=github)](https://coveralls.io/github/Pipend/pipend-spy?branch=master)

# Spy
Spy is a database agnostic event recording library for node.js.

# Install
* `npm install pipend-spy`
* (Optional) next, run `npm run download-ip-country-db` in the directory of this package which downloads the ip country database (`IP-COUNTRY.BIN` file) to the data directory of the said package, by default it uses the free lite version from http://download.ip2location.com/lite/, but you can use a licensed version for more accuracy instead, just make sure you rename the bin file to `IP-COUNTRY.BIN`

# Usage
Spy exports a function with the signature `[StorageDetails] -> Spy`, i.e. it takes a collection of storage details (see the [StorageDetails section](#supported-stores) for information about the different stores supported) and returns an object with 2 methods, record & recordReq.

* livescript
```
{record, record-req} = (require \pipend-spy) do 
    * name: \mongo
      connection-string: \mongodb://localhost:27017/test
      connection-options: {}
      insert-into:
        collection: \events
    ...

event =  
    event-type: \visit
    user-id: 1234567890
    session-id: 1234567890

record event .then (inserted) ->
    console.log \event-inserted, inserted

app.get \/, (req, res) ->
    record-req req, event .then (inserted) -> console.log \event-inserted-with-req, inserted
    res.end \hello
```

* javascript
```
spy = require("pipend-spy")([{
  name: "mongo",
  connectionString: "mongodb://localhost:27017/test",
  connectionOptions: {},
  insertInto: {
    collection: "events"
  }
}]);

event = {
  eventType: "visit",
  userId: 1234567890,
  sessionId: 1234567890
}

spy.record(event).then(function(inserted){
  console.log("event-inserted", inserted);
});

app.get("/", function(req, res){
  spy.recordReq("event").then(function(inserted){
    console.log("event-inserted-with-req", inserted);
  });
  res.end("hello");
});

```

# Supported Stores
* MongoDB
  Storage details object for MongoDB : 
```
{
    "name": "mongo"
    "connectionString": "mongodb://host:port/database"
    "connectionOptions": {} // passed directly to the node.js mongodb driver as connectionOptions
    "insertInto": {
        "collection": "collection" // name of the mongodb collection to insert data into
    }
}
```

# Methods
|    Name     |   Type                                |   Description                  |
|-------------|---------------------------------------|--------------------------------|
| record      | Event -> p [InsertedEvent]            | `spy.record({})`, accepts any JSON object and returns a collection of objects inserted - one for each store - wrapped in a Promise |
| recordReq   | Request -> Event -> p [InsertedEvent] | `spy.recordReq(req, {})`, extends the JSON object - passed in as the last argument - with "useful" information from the node.js request object - passed in as the first argument - | 

# Information captured from the request object
When using `Spy.recordReq` method, Spy adds the following information to the event object (for example):
```
{
    "creationDate": "2015-01-01T00:00:00.000Z",
    "creationTime": 1420056000000,
    "ip": "127.0.0.1",
    "ipTokens": {
        "ip2": "127.0",
        "ip3": "127.0.0"
    },
    "country": "-",
    "headers": {
        "userAgent": "test"
    },
    "uaTokens": {
        "ua": "",
        "browser": {},
        "engine": {},
        "os": {},
        "device": {},
        "cpu": {}
    },
    "url": "http://://localhost",
    "queryTokens": {}
}
```
Note: `creationTime` & `creationDate` are also added by the `Spy.record` method.

# Status
Needs more unit tests & stores.

# Development
* `npm install`
* run `npm run download-ip-country-db` to download ip-country data
* run `gulp` to build & watch
* `npm test` & `npm run coverage` for unit testing and coverage reports
