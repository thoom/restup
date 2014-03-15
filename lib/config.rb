require 'yaml'

module Thoom
  class ConfigError < RuntimeError
    attr_reader :message

    def initialize(message)
      @message = message
    end
  end

  class Config
    def initialize(filename, env = :default)
      file = (File.exists? filename) ? filename : File.expand_path("~/#{ filename }")

      raise ConfigError.new "Configuration file #{ file } not found" unless File.exists? file

      @config = YAML.load_file file
      @env    = env
    end

    def get(key, val = nil)
      if @config.has_key?(@env) && @config[@env].has_key?(key)
        @config[@env][key]
      elsif @config.has_key?(:default) && @config[:default].has_key?(key)
        @config[:default][key]
      elsif @config.has_key? key
        @config[key]
      elsif !val.nil?
        val
      else
        raise ConfigError.new "Missing configuration entry for #{ key }"
      end
    end

    def env=(val)
      @env = val.to_sym
    end
  end
end