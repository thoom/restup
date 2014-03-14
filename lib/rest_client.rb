require 'json'
require 'logger'
require 'net/http'
require 'openssl'
require 'uri'
require 'yaml'

module Thoom
  class RestClient

    VERSION = '0.8.5'
    MIME_JSON = 'application/json'
    MIME_XML = 'application/xml'

    attr_accessor :method, :endpoint, :headers, :data, :cert
    attr_reader :log, :env

    def initialize
      file_name = '.restclient.yml'
      file = (File.exists? file_name) ? file_name : File.expand_path("~/#{ file_name }")

      raise "Configuration file #{ file } not found" unless File.exists? file

      @config = YAML.load_file file
      @env = :default
      @log = Logger.new STDOUT

      @headers = []

      @standard_methods = %w(delete get head options patch post put)
    end

    def request
      set_env_defaults(@env)

      m = method.downcase
      return 'Invalid Method' unless (@standard_methods.include? m) || (xmethods.include? m)

      if xmethods.include? m
        headers << "X-HTTP-Method-Override: #{ m.upcase }"
        m = 'post'
      end

      request_uri = uri.request_uri
      request = Net::HTTP.const_get(m.capitalize).new request_uri

      unless user.to_s.empty? || pass.to_s.empty?
        request.basic_auth(user, pass)
      end

      request['User-Agent'] = 'Thoom::RestClient/' + VERSION
      request.content_length = 0

      if m == 'post'
        #This just sets a default to JSON
        request.content_type = get_config_val(:json, MIME_JSON) if request.content_type.nil? || request.content_type.empty?
      end

      if headers.respond_to? :each
        headers.each do |header|
          key, value = header.split ':'
          request[key.strip] = value.strip
        end
      end

      body = data
      if body
        if request.content_type == 'application/x-www-form-urlencoded'
          json = JSON.parse(body)
          body = URI.encode_www_form(json)
        end

        request.content_length = data.length
        request.body = body
      end

      request
    end

    def submit(request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = get_config_val(:timeout, 300)

      if uri.scheme == 'https'
        http.use_ssl = true

        verify_mode = get_config_val(:tls_verify, 'VERIFY_PEER').upcase
        raise 'tls_verify only accepts VERIFY_PEER or VERIFY_NONE' unless %w(VERIFY_PEER VERIFY_NONE).include? verify_mode

        http.verify_mode = OpenSSL::SSL.const_get(verify_mode)
      end

      unless pem.nil? || pem.empty?
        f = File.read pem

        http.cert = OpenSSL::X509::Certificate.new f
        http.key = OpenSSL::PKey::RSA.new f
      end

      http.request request

      #if response.code.to_i == 301
      #  newloc = response.header['location'][response.header['location'].index('rest/api/')+8..-1]
      #
      #  puts "301 Redirected to new endpoint: #{newloc}".red
      #
      #  @uri = nil
      #  self.endpoint = newloc
      #
      #  response = submit(self.request)
      #end
    end

    def pem
      return cert unless cert.nil?

      get_config_val(:cert, '')
    end

    def uri
      return @uri if @uri

      @uri = URI.parse url
    end

    def base
      get_config_val(:url)
    end

    def url
      base + endpoint
    end

    def xmethods
      get_config_val(:xmethods, [])
    end

    def user
      get_config_val(:user, '')
    end

    def pass
      get_config_val(:pass, '')
    end

    def env=(val)
      @env = val.to_sym
      set_env_defaults(@env)
    end

    def set_env_defaults(e)
      h = get_config_val(:headers, '')
      if h.respond_to? :each
        h.each do |header|
          headers << header
        end
      end
    end

    def get_config_val(key, val = nil)
      if @config.has_key?(env) && @config[env].has_key?(key)
        @config[env][key]
      elsif @config.has_key?(:default) && @config[:default].has_key?(key)
        @config[:default][key]
      elsif @config.has_key? key
        @config[key]
      elsif !val.nil?
        val
      else
        raise "Missing configuration entry for #{ key }"
      end
    end
  end
end
