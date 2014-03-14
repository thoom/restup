Thoom::RestClient
=================

The RestClient works with APIs that use Basic Authentication. To use other forms of
authentication, custom headers can be stored in the config file as described below.

It uses a `.restclient.yml` file to pull in defaults and provides several shortcut methods
that can simplify using a REST-based API.

If the API uses form encoded input, you need to define your post in JSON format. The client
will encode it automatically.

Version
-------

0.7.0: Removed dependency on Nokogiri for XML parsing.

0.7.5: Added option to change the request timeout. Added option to disable TLS cert validation (Useful with self-signed certs).

0.8.4: Added option to save response to a file by passing in the -o {file} arg. For binary files, response is never output in summary.
0.8.5: Added option to save response to the filename in the content-disposition if that header is passed.

Installation
------------

For convenience, the executable and class are available as a gem on RubyGems.

    gem install restclient

Flags
-----

	ARGUMENT    DESC
	--------    -----
	--concise   Disables verbose output
	--content-disposition
                For responses with a filename in the Content Disposition, save the response using that filename
	--form      Converts JSON-formatted input and encode it as x-www-form-urlencoded

	-j          Sets JSON Content-Type and Accept headers based on the :json: config MIME type
	-jc         Sets JSON Content-Type header
	-ja         Sets JSON Accept header

	-x          Sets XML Content-Type and Accept headers based on the :xml: config MIME type
	-xc         Sets XML Content-Type header
	-xa         Sets XML Accept header

	-c {cert}   Imports cert for Client-Authentication endpoints
	-d {data}   Sets data string as POST body
	-e {env}    Sets YAML environment for the request
	-f {file}   Imports file as POST body (assumes file based on current location)
	-h {header} Sets arbitrary header passed in format "HEADER: VALUE"
	-o {file}   Save output to file passed

YAML config
-----------

The client uses two different methods to find the YAML file `.restclient.yml`. It will
first look in the current directory. If it is not present, it will then look in the current user's
home directory.

This makes it possible to use the restclient to connect to different APIs simply by changing
folders.

	KEY          DESC
	----         -----
	:user:       The username. If missing or blank, the client will not use Basic Authentication
	:pass:       The password. If missing or blank, the client will not use Basic Authentication

	:url:        The base REST url
	:json:       The default JSON MIME type. If missing, the client uses "application/json"
	:xml:        The default XML MIME type. If missing, the client uses "application/xml"

	:headers:    Array of default headers. Useful for custom headers or headers used in every request
    :timeout:    The number of seconds to wait for a response before timing out. If missing, the client uses 300
    :tls_verify: When using TLS, the verify mode to use. Valid values are: VERIFY_NONE, VERIFY_PEER.
                 If missing, the client will use VERIFY_PEER
	:xmethods:   Array of nonstandard methods that are accepted by the API. To use these methods the
				 API must support X-HTTP-Method-Override.

Examples
--------

### GET Request

The YAML config:

	:url: http://example.com/api
	:user: myname
	:pass: P@ssWord

The command line:

	restclient get /hello/world -j

Submits a GET request to `http://example/api/hello/world` with Basic Auth header using the
user and pass values in the config.

It would return JSON values. If successful, the JSON would be parsed and highlighted in __GREEN__. If
the an error was returned (an HTTP response code >= 400), the body would be in __RED__.

### POST Request

The YAML config:

	:url: http://example.com/api
	:user: myname
	:pass: P@ssWord

The command line:

	restclient post /hello/world -j -f order.json

Submits a POST request to `http://example/api/hello/world` with Basic Auth header using the
user and pass values in the config. It imports the order.json and passes it to the API as application/json
content type.

It would return JSON values. If successful, the JSON would be parsed and highlighted in __GREEN__. If
the an error was returned (an HTTP response code >= 400), the body would be in __RED__.
