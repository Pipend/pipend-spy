{IP2Location_init, IP2Location_get_all} = require \ip2location-nodejs
{last} = require \prelude-ls

# initialize IP2Location
IP2Location_init "#{__dirname}/data/IP-COUNTRY.BIN"

# get-ip-from-request :: Request -> String
export get-ip-from-request = (req) ->
    (
        req?.query?['x-ip'] or 
        req?.headers?['x-forwarded-for'] or 
        req?.connection?.remoteAddress or 
        req?.socket?.remoteAddress or 
        req?.connection?.socket?.remoteAddress
    )?.split \: ?.0 ?.trim!

# get-country-from-ip :: String -> String
export get-country-from-ip = (ip) -> (IP2Location_get_all ip).country_short

