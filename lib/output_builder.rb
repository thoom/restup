require 'constants'

require 'json'
require 'paint'
require 'rexml/document'
require 'rexml/formatters/pretty'

module Thoom
  class OutputBuilder
    attr_accessor :colors, :title_output, :response_time

    def initialize(colors)
      @colors = colors
      @output = ''
    end

    def title(centered = true)
      return if title_output

      client_copy = "Thoom::RestUp v#{Thoom::Constants::VERSION}"
      author_copy = '@author Z.d. Peacock <zdp@thoomtech.com>'
      link_copy   = '@link http://github.com/thoom/restup'

      if centered
        max         = [client_copy.length, author_copy.length, link_copy.length].max + 2
        client_copy = client_copy.center(max, ' ')
        author_copy = author_copy.center(max, ' ')
        link_copy   = link_copy.center(max, ' ')
      end

      @title_output = true
      puts "\n",
           Paint[client_copy, colors[:title_color], colors[:title_bgcolor]],
           Paint[author_copy, colors[:subtitle_color], colors[:subtitle_bgcolor]],
           Paint[link_copy, colors[:subtitle_color], colors[:subtitle_bgcolor]]
    end

    def header(h)
      len = Paint.unpaint(h).length
      l   = '-' * len
      puts "\n#{h}\n#{l}\n"
    end

    def help(config_file, opts)
      title
      section 'How to use RestUp'

      puts <<TEXT
RestUp works out of the box with APIs that use Basic Authentication (though this is not required).
To use other forms of authentication, custom headers can either be passed with each request
or stored in the config file as described below.

If a #{Paint[config_file, colors[:help_filename]]} file exists, the client will pull in defaults and provide several shortcut methods
that can simplify using a REST-based API.

If the API uses form encoded input, you can define your post in JSON format. The client
will encode it automatically.
TEXT

      section 'Console'
      puts opts

      section 'YAML config'
      puts <<TEXT
If a file is not passed in with the `-c, --config` flag, then it will use the default #{Paint[config_file, colors[:help_filename]]}.
The client uses two different methods to find the YAML configuration file. It will
first look in the current directory. If it is not present, it will then look in the current user's
home directory.

This makes it possible to use restup to connect to different APIs simply by changing folders.

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
TEXT

      section 'Examples'

      header 'GET Request'

      puts <<TEXT
The YAML config:
url: http://example.com/api
user: myname
pass: P@ssWord

#{Paint['restup -j /hello/world', colors[:help_sample_request]]}

To use without the config:
#{Paint['restup -u myname -p P@ssWord -j http://example.com/api/hello/world', colors[:help_sample_request]]}

Submits a GET request to #{Paint['http://example/api/hello/world', colors[:help_sample_url]]} with Basic Auth header using the
user and pass values in the config.

It would return JSON values. If successful, the JSON would be parsed and highlighted in #{Paint[colors[:success].to_s.upcase, colors[:success]]}. If
the an error was returned (an HTTP response code >= 400), the body would be in #{Paint[colors[:error].to_s.upcase, colors[:error]]}.
TEXT

      header 'POST Request'

      puts <<TEXT
The YAML config:
url: http://example.com/api
user: myname
pass: P@ssWord
headers:
  X-Custom-Id: abc12345

#{Paint['restup -m post -j /hello/world < salutation.json', colors[:help_sample_request]]}

Submits a POST request to #{Paint['http://example/api/hello/world', colors[:help_sample_url]]} with Basic Auth header
using the user and pass values in the config. It imports the salutation.json and passes it to the API as application/json
content type. It would also set the X-Custom-Id header with every request.

It would return JSON values. If successful, the JSON would be parsed and highlighted in #{Paint[colors[:success].to_s.upcase, colors[:success]]}. If
the an error was returned (an HTTP response code >= 400), the body would be in #{Paint[colors[:error].to_s.upcase, colors[:error]]}.
TEXT
      exit
    end

    def section(h)
      len = Paint.unpaint(h).length
      l   = '-' * (len + 4)
      puts "\n#{l}\n| #{h} |\n#{l}\n"
    end

    def xp(xml_text)
      out = ''

      formatter = REXML::Formatters::Pretty.new
      formatter.compact = true
      formatter.write(REXML::Document.new(xml_text), out)
      out
    end

    def request(client, request, verbose)
      path  = client.uri.path
      query = ''
      query += '?' + client.uri.query if client.uri.query

      port_color      = client.uri.port == 80 ? :request_port_http : :request_port_tls
      request_section = "REQUEST: #{Paint[client.method.upcase, colors[:request_method]]} "
      request_section += Paint["#{client.uri.host}:", colors[:request_path]]
      request_section += Paint[client.uri.port.to_s, colors[port_color]]
      request_section += Paint[path, colors[:request_path]]
      request_section += Paint[query, colors[:request_endpoint]]

      unless request.respond_to? 'each_header'
        header 'MALFORMED REQUEST'
        quit Paint[request, colors[:error]]
      end

      if verbose
        section request_section if verbose

        header 'HEADERS'
        request.each_header { |k, v| puts "#{k}: #{v}\n" }

        if client.data
          header 'BODY'

          begin
            puts %w(UTF-8 ASCII-8BIT).include?(client.data.encoding.to_s) ? client.data : client.data.encode('ASCII-8BIT')
          rescue EncodingError
            puts "Data posted, but contains non-UTF-8 data, so it's not echoed here."
          end
        end
      else
        puts "\n#{request_section}"
      end
    end

    def response(response, verbose)
      response_color   = response.code.to_i < 400 ? colors[:success] : colors[:error]
      response_section = "RESPONSE: #{Paint[response.code, response_color]} (#{response_time} sec)"

      if verbose || response_color == colors[:error]
        section response_section
        header 'HEADERS'
        response.each_header { |k, v| puts "#{k}: #{v}\n" }
      else
        puts response_section
      end

      header 'BODY' if verbose
      puts 'BODY:' unless verbose

      if !response.body || response.body.empty?
        puts Paint['NONE', colors[:info]]
      else
        body = response.body
        begin
            body.encode!('ASCII-8BIT') if body.encoding.to_s != 'ASCII-8BIT'

            body = if response['content-type'].nil?
                     body
                   elsif response['content-type'].include? 'json'
                     JSON.pretty_unparse(JSON.parse(body))
                   elsif response['content-type'].include? 'xml'
                     xp(body)
                   else
                     body
               end
            puts Paint[body, response_color]
          rescue EncodingError => e
            puts Paint["RESPONSE contains non-UTF-8 data, so it's not echoed here.", colors[:info]]
          end
      end
    end

    def save_response(response, content_disposition, output)
      if content_disposition && output.nil? && response.to_hash.key?('content-disposition')
        cd = response['content-disposition']
        output = cd[cd.index('filename=') + 9..-1]
      end

      unless output.nil?
        file = File.expand_path(output)
        if File.exist?(File.dirname(file))
          File.open(file, 'w') { |f| f.write response.body }
          puts Paint["Response written to file: #{file}", colors[:info]]
        else
          puts Paint["Could not write to file #{file}", colors[:error]]
        end
      end
    end

    def quit(content, centered = true)
      title(centered)
      puts "\n#{content}"
      exit
    end
  end

  # Sets up the default color set
  class DefaultOutputBuilder < OutputBuilder
    def initialize
      colors = {
        title_color: '4D7326',
        title_bgcolor: :white,

        subtitle_color: :white,
        subtitle_bgcolor: '4D7326',

        help_filename: :yellow,
        help_sample_request: :magenta,
        help_sample_url: :blue,

        request_method: :cyan,
        request_path: '813b5e',
        request_port_http: '813b5e',
        request_port_tls: '264d73',
        request_endpoint: :yellow,

        success: '277326',
        warning: :yellow,
        info: :yellow,
        error: 'c20f12'
      }
      super(colors)
    end
  end

  # Outputs just the basic default colors
  class SimpleOutputBuilder < OutputBuilder
    def initialize
      colors = {
        subtitle_color: :default,
        subtitle_bgcolor: :default,
        title_color: :default,
        title_bgcolor: :default
      }
      super(colors)
    end
  end
end
