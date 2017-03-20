require 'yaml'
require 'logger'
require 'net/http'
require 'openssl'
require 'uri'
require 'config'
require 'constants'

module Thoom
  # General Error message returned by the class
  class RestUpError < RuntimeError
    attr_reader :message

    def initialize(message)
      @message = message
    end
  end

  # Makes the request
  class RestUp
    attr_accessor :endpoint, :data, :cert
    attr_reader :headers, :log, :method

    def initialize(config = nil)
      @config = config.nil? ? HashConfig.new : config
      @log = Logger.new STDOUT

      @uri = nil
      @xmethods = nil
      @headers = @config.get(:headers, {})
      @standard_methods = %w(delete get head options patch post put)
    end

    def headers=(headers)
      headers.each { |key, val| @headers[key.to_sym] = val }
    end

    def method=(method)
      method.downcase!

      unless @standard_methods.include?(method) || xmethods.include?(method)
        raise RestUpError, 'Invalid Method'
      end

      if xmethods.include? method
        headers['x-http-method-override'] = method.upcase
        method = 'post'
      end

      @method = method
    end

    def request
      raise RestUpError, 'Invalid URL' unless uri.respond_to?(:request_uri)

      request = create_request(uri.request_uri)

      add_request_headers(request)
      add_request_body(request)

      request
    end
    
    def http
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = @config.get(:timeout, 300)

      configure_tls http
      configure_client_cert http

      http
    end

    def submit(request)
      http.request request
    end

    def uri
      return @uri if @uri
      @uri = URI.parse url
    end

    def url
      return endpoint if endpoint.start_with?('http')

      @config.get(:url, '') + endpoint
    end

    private

    def create_request(request_uri)
      request = Net::HTTP.const_get(method.capitalize).new request_uri

      configure_basic_auth(request)

      request['User-Agent']  = 'Thoom::RestUp/' + Constants::VERSION
      request.content_length = 0

      request
    end

    def configure_basic_auth(request)
      user = @config.get(:user, '')
      pass = @config.get(:pass, '')

      request.basic_auth(user, pass) unless user.to_s.empty? || pass.to_s.empty?
    end

    def configure_client_cert(http)
      pem = cert.nil? ? @config.get(:cert, '') : cert
      return if pem.empty?

      begin
        http.cert = OpenSSL::X509::Certificate.new pem
        http.key  = OpenSSL::PKey::RSA.new pem
      rescue OpenSSL::OpenSSLError
        raise RestUpError.new 'Invalid client certificate'
      end
    end

    def configure_tls(http)
      return if uri.scheme != 'https'
      http.use_ssl = true

      mode = @config.get(:tls_verify, true) ? 'VERIFY_PEER' : 'VERIFY_NONE'
      http.verify_mode = OpenSSL::SSL.const_get(mode)
    end

    def add_request_body(request)
      return if data.nil? || data.empty?

      body = data.clone
      request.content_length = body.length
      request.body = body
    end

    def add_request_headers(request)
      return unless headers.respond_to? :each

      headers.each { |key, val| request[key.to_s.strip] = val.strip }
    end
    
    def xmethods
      return @xmethods if @xmethods

      xmethods = @config.get(:xmethods, [])
      unless xmethods.respond_to? :map
        raise RestUpError.new 'Invalid xmethods configuration'
      end

      @xmethods = xmethods.map(&:downcase)
    end
  end
end
