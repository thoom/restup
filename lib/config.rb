require 'yaml'

module Thoom
  class Config
    def initialize(filename, env = :default)
      file = (File.exists? filename) ? filename : File.expand_path("~/#{ filename }")

      raise "Configuration file #{ file } not found" unless File.exists? file

      @config = YAML.load_file file
      @env    = env
    end

    def get(key, val = nil)
      if @config.has_key?(@env) && @config[@env].has_key?(key)
        @config[@env][key]
      elsif @config.has_key?(:default) && @config[:default].has_key?(key)
        @config[@env][key]
      elsif @config.has_key? key
        @config[key]
      elsif !val.nil?
        val
      else
        raise "Missing configuration entry for #{ key }"
      end
    end

    def env=(val)
      @env = val
    end
  end
end