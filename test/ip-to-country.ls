assert = require \assert
{get-ip-from-request, get-country-from-ip} = require \../ip-to-country

describe "ip-to-country", ->

    test-ip = \50.5.0.0

    specify "must return ip from request", (done) ->
        ip = get-ip-from-request do 
            socket:
                remote-address: test-ip
        assert ip == test-ip, "ip must be #{test-ip} instead of #{ip}"
        done!

    specify "must return country from ip", (done) ->
        country = get-country-from-ip test-ip
        assert country == \US, "country must be AE instead of #{country}"
        done!