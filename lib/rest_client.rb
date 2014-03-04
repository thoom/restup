#!/usr/bin/env ruby

require 'colored'
require 'json'
require 'logger'
require 'net/http'
require 'openssl'
require 'uri'
require 'yaml'

module Thoom
  class RestClient

    VERSION = 0.6

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

      @standard_methods = %w(get head options post patch put)
    end

    def request
      m = method.downcase
      return 'Invalid Method' unless (@standard_methods.include? m) || (xmethods.include? m)

      if xmethods.include? m
        headers << "X-HTTP-Method-Override: #{ m.upcase }"
        m = 'post'
      end

      request_uri = uri.request_uri
      request = Net::HTTP.const_get(m.capitalize).new request_uri

      if user && pass
        request.basic_auth(user, pass)
      end

      request['User-Agent'] = 'Thoom::RestClient/' + VERSION.to_s
      request['Content-Length'] = 0

      if m == 'post'
        request['Content-Type'] = get_config_val(:json) #This just sets a default to JSON
      end

      if headers.respond_to? :each
        headers.each do |header|
          key, value = header.split ':'
          request[key.strip] = value.strip
        end
      end

      if data
        request['Content-Length'] = data.length

        if request['Content-Type'] == 'application/x-www-form-urlencoded'
          json = JSON.parse(data)
          data = URI.encode_www_form(json)
        end

        request.body = data
      end

      request
    end

    def submit(request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = get_config_val(:timeout, 300)

      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      unless pem.nil? || pem.empty?
        f = File.read pem

        http.cert = OpenSSL::X509::Certificate.new f
        http.key = OpenSSL::PKey::RSA.new f
      end

      response = http.request request

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

      response
    rescue Timeout::Error => e
      puts "\nRequest timed out".red
    end

    def pem
      return cert unless cert.nil?

      cert = get_config_val(:cert, '')
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
        puts "header responds to each"
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
