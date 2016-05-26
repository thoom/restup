Thoom::RestClient
=================

The RestClient works out of the box with APIs that use Basic Authentication (though this is not required). 
To use other forms of authentication, custom headers can either be passed with each request
or stored in the config file as described below.

If a `.restclient.yml` file exists, the client will pull in defaults and provide several shortcut methods
that can simplify using a REST-based API.

If the API uses form encoded input, you can define your post in JSON format. The client
will encode it automatically.

Installation
------------

For convenience, the executable and class are available as a gem on RubyGems.

    gem install restclient

Console
-------

    Usage: restclient METHOD ENDPOINT [options]
            --concise                    Disables verbose output
            --content-disposition        For responses with a filename in the Content Disposition, save the response using that filename
            --form                       Converts JSON-formatted input and encode it as x-www-form-urlencoded
            --response-only              Only outputs the response body
            --response-code-only         Only outputs the response code
            --success-only               Only outputs whether or not the request was successful
        -c, --cert CERTFILE              Imports cert for Client-Authentication endpoints
        -e, --env ENVIRONMENT            Sets YAML environment for the request
        -h, --header HEADER              Sets arbitrary header passed in format "HEADER: VALUE"
        -j, --json [c|a]                 Sets the Content-Type and/or Accept Headers to use JSON mime types (i.e. -ja)
        -o, --output FILE                Save output to file passed
        -p, --password PASSWORD          Password for Basic Authentication
        -u, --username USERNAME          Username for Basic Authentication
        -x, --xml [c|a]                  Sets the Content-Type and/or Accept Headers to use XML mime types (i.e. -xc)
            --version                    Shows client version
            --help [details]             Shows this message

YAML config
-----------

The client uses two different methods to find the YAML file `.restclient.yml`. It will
first look in the current directory. If it is not present, it will then look in the current user's
home directory.

This makes it possible to use the restclient to connect to different APIs simply by changing
folders.

    KEY          DESC
    ----         -----
    user:       The username. Default: blank, so disable Basic Authentication
    pass:       The password. Default: blank, so disable Basic Authentication

    url:        The base REST url
    json:       The default JSON MIME type. Default: "application/json"
    xml:        The default XML MIME type.  Default: "application/xml"
  
    colors:     Hash of default color values
      success:  Color to highlight successful messages.  Default: :green
      warning:  Color to highlight warning messages.     Default: :yellow
      info:     Color to highlight info messages.        Default: :yellow
      error:    Color to highlight error messages.       Default :red

    headers:    Hash of default headers. Useful for custom headers or headers used in every request.
                The keys for this hash are strings, not symbols like the other keys
    
    timeout:    The number of seconds to wait for a response before timing out. Default: 300
    
    tls_verify: When using TLS, the verify mode to use.  Values: true, false.  Default: true
    
    xmethods:   Array of nonstandard methods that are accepted by the API. To use these methods the
                API must support X-HTTP-Method-Override.

Examples
--------

### GET Request

The YAML config:

    url: http://example.com/api
    user: myname
    pass: P@ssWord

The command line:

    restclient get /hello/world -j
    
To use without the config:

    restclient get http://example.com/api/hello/world -u myname -p P@ssWord -j

Submits a GET request to `http://example/api/hello/world` with Basic Auth header using the
user and pass values in the config.

It would return JSON values. If successful, the JSON would be parsed and highlighted in __:colors::success:__. If
the an error was returned (an HTTP response code >= 400), the body would be in __:colors::error:__.

### POST Request

The YAML config:

    url: http://example.com/api
    user: myname
    pass: P@ssWord
    headers:
      X-Custom-Id: abc12345

The command line:

    restclient post /hello/world -j < salutation.json
    
OR

    cat salutation.json | restclient post /hello/world 

Submits a POST request to `http://example/api/hello/world` with Basic Auth header using the
user and pass values in the config. It imports the salutation.json and passes it to the API as application/json
content type. It would also set the `X-Custom-Id` header with every request.

It would return JSON values. If successful, the JSON would be parsed and highlighted in __:colors::success:__. If
the an error was returned (an HTTP response code >= 400), the body would be in __:colors::error:__.

License
-------
[MIT](LICENSE)

Version History
---------------
[Changelog](CHANGELOG.md)
