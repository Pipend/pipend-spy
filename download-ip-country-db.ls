Download = require \download
{chmod, rename, unlink} = require \fs
require! \mkdirp
{map} = require \prelude-ls

data-directory = "#{__dirname}/data/"

<- mkdirp data-directory
<- unlink "#{data-directory}IP-COUNTRY.BIN"
new Download {extract: true}
    .get \http://download.ip2location.com/lite/IP2LOCATION-LITE-DB1.BIN.ZIP
    .dest data-directory
    .run (err, files) ->
        <- rename "#{data-directory}IP2LOCATION-LITE-DB1.BIN", "#{data-directory}IP-COUNTRY.BIN"
        <- chmod "#{data-directory}IP-COUNTRY.BIN", \644
        console.log \done