Thoom::RestUp
=============

After many years in beta, RestClient is now RestUp version 1. 
It's mainly the same client as before, but some breaking changes have been made based on 
feedback and experience.

RestUp works out of the box with APIs that use Basic Authentication (though this is not required).
To use other forms of authentication, custom headers can either be passed with each request
or stored in the config file as described below.

If a YAML configuration file exists (by default `.restup.yml`), the client will pull in defaults and provide several shortcut methods that can simplify using a REST-based API.

If the API uses form encoded input, you can define your post in JSON format. The client
will encode it automatically.

Installation
------------

#### Gem
For convenience, the executable and class are available as a gem on RubyGems.

    gem install restup

#### Docker
The client is also available as a Docker image.

To install:

    docker pull thoom/restup

To run:

    docker run --rm -v $PWD:/restup thoom/restup

A sample shell script `restup`:

    #!/bin/bash
    docker run --rm -v $PWD:/restup thoom/restup "@"

Console
-------

    Usage: restclient [options] ENDPOINT
            --concise                    Simplified response view
            --content-disposition        For responses with a filename in the Content Disposition, save the response using that filename
            --form                       Converts JSON-formatted input and encode it as x-www-form-urlencoded
            --response-only              Only outputs the response body
            --response-code-only         Only outputs the response code
            --success-only               Only outputs whether or not the request was successful
            --cert CERTFILE              Imports cert for Client-Authentication endpoints
        -c, --config FILE                Config file to use. Defaults to .restup.yml
        -e, --env ENVIRONMENT            Sets YAML environment for the request
        -h, --header HEADER              Sets arbitrary header passed in format "HEADER: VALUE"
        -j, --json [c|a]                 Sets the Content-Type and/or Accept Headers to use JSON mime types (i.e. -ja)
        -m, --method                     The HTTP method to use (defaults to GET)
        -o, --output FILE                Save output to file passed
        -p, --password PASSWORD          Password for Basic Authentication
        -u, --username USERNAME          Username for Basic Authentication
        -x, --xml [c|a]                  Sets the Content-Type and/or Accept Headers to use XML mime types (i.e. -xc)
            --verbose                    Expanded response view
            --version                    Shows client version
            --help [details]             Shows this help dialog

YAML config
-----------

If a file is not passed in with the `-c, --config` flag, then it will use the default `.restup.yml`.
The client uses two different methods to find the YAML configuration file.
It will first look in the current directory. 
If it is not present, it will then look in the current user's home directory.

This makes it possible to use restup to connect to different APIs simply by changing
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
      
    flags:      Default command line options
      display:  What to display by default. 
                Values: concise, response_only, response_code_only, succcess_only, verbose
                Default: response_only

    headers:    Hash of default headers. Useful for custom headers or headers used in every request.
    timeout:    The number of seconds to wait for a response before timing out. Default: 300
    tls_verify: Whether or not to verify TLS (SSL) certificates.  Values: true, false.  Default: true

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

    restup -j /hello/world 

To use without the config:

    restclient -u myname -p P@ssWord -j http://example.com/api/hello/world

Submits a GET request to `http://example/api/hello/world` with Basic Auth header using the
user and pass values in the config.

It would return JSON values. If successful, the JSON would be parsed and highlighted in __colors['success']__. If
the an error was returned (an HTTP response code >= 400), the body would be in __colors['error']__.

### POST Request

The YAML config:

    url: http://example.com/api
    user: myname
    pass: P@ssWord
    headers:
      X-Custom-Id: abc12345

The command line:

    restclient -m post -j /hello/world < salutation.json

OR

    cat salutation.json | restclient -m post /hello/world

Submits a POST request to `http://example/api/hello/world` with Basic Auth header using the
user and pass values in the config. It imports the salutation.json and passes it to the API as application/json
content type. It would also set the `X-Custom-Id` header with every request.

It would return JSON values. If successful, the JSON would be parsed and highlighted in __colors['success']__. If
the an error was returned (an HTTP response code >= 400), the body would be in __colors['error']__.


Migration From RestClient
-------------------------

To migrate:

1. Rename your `.restclient.yml` file to `.restup.yml`.
2. The CLI format changed from `restclient METHOD ENDPOINT [options]` to `restup [options] ENDPOINT`.
3. The `-c` option is no longer available. You must use `--cert` instead.
4. The `-m` option was created for specifying methods. So `restup -m POST ENDPOINT` instead of `restclient POST ENDPOINT`.
5. Add `flags: { display: verbose }` to the config file return to the previous API output.

License
-------
[MIT](LICENSE)

Version History
---------------
[Changelog](CHANGELOG.md)
