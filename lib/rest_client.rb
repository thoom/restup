require 'json'
require 'logger'
require 'net/http'
require 'openssl'
require 'uri'
require 'config'
require 'constants'

module Thoom
  class RestClientError < RuntimeError
    attr_reader :message

    def initialize(message)
      @message = message
    end
  end

  class RestClient
    attr_accessor :method, :endpoint, :headers, :data, :cert
    attr_reader :log

    def initialize(config = nil)
      @config = config.nil? ? HashConfig.new : config
      @log = Logger.new STDOUT

      @headers = {}
      @standard_methods = %w(delete get head options patch post put)
    end

    def request
      m = method.downcase

      raise RestClientError, '":xmethods:" should be an array' unless xmethods.respond_to? :include?
      raise RestClientError, 'Invalid Method' unless (@standard_methods.include? m) || (xmethods.include? m)

      if xmethods.include? m
        headers['x-http-method-override'] = m.upcase
        m = 'post'
      end

      raise RestClientError, 'Invalid URL' unless uri.respond_to?('request_uri')

      request_uri = uri.request_uri
      request     = Net::HTTP.const_get(m.capitalize).new request_uri

      request.basic_auth(user, pass) unless user.to_s.empty? || pass.to_s.empty?

      request['User-Agent']  = 'Thoom::RestClient/' + Constants::VERSION
      request.content_length = 0

      # This just sets a default to JSON
      request.content_type   = @config.get(:json, Constants::MIME_JSON) if %w(post put patch).include?(m) && (request.content_type.nil? || request.content_type.empty?)

      headers.each { |key, val| request[key.to_s.strip] = val.strip } if headers.respond_to? :each

      body = data
      if body
        if request.content_type == 'application/x-www-form-urlencoded'
          json = JSON.parse(body)
          body = URI.encode_www_form(json)
        end

        request.content_length = data.length
        request.body           = body
      end

      request
    end

    def submit(request)
      http              = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = @config.get(:timeout, 300)

      if uri.scheme == 'https'
        http.use_ssl = true

        verify_mode      = @config.get(:tls_verify, true) ? 'VERIFY_PEER' : 'VERIFY_NONE'
        http.verify_mode = OpenSSL::SSL.const_get(verify_mode)
      end

      unless pem.nil? || pem.empty?
        f = File.read pem

        http.cert = OpenSSL::X509::Certificate.new f
        http.key  = OpenSSL::PKey::RSA.new f
      end

      http.request request

      # TODO: This was originally hardcoded... probably need to figure out a resolution some day
      # if response.code.to_i == 301
      #  newloc = response.header['location'][response.header['location'].index('rest/api/')+8..-1]
      #
      #  puts "301 Redirected to new endpoint: #{newloc}".red
      #
      #  @uri = nil
      #  self.endpoint = newloc
      #
      #  response = submit(self.request)
      # end
    end

    def pem
      return cert unless cert.nil?
      @config.get(:cert, '')
    end

    def uri
      return @uri if @uri
      @uri = URI.parse url
    end

    def base
      @config.get(:url, '')
    end

    def url
      base + endpoint
    end

    def xmethods
      @config.get(:xmethods, [])
    end

    def user
      @config.get(:user, '')
    end

    def pass
      @config.get(:pass, '')
    end
  end
end
