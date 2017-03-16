require 'minitest/autorun'
require_relative '../lib/config.rb'

# Test the configuration system
class TestConfig < MiniTest::Unit::TestCase
  def setup
    hash = {
      url: 'http://github.com/thoom/restup',
      mime_json: 'application/json',
      second_env: { url: 'http://github.com/thoom' }
    }
    @config = Thoom::HashConfig.new hash
  end

  def test_default_env
    @config.env = :default
    assert_equal 'http://github.com/thoom/restup', @config.get(:url)
    assert_equal 'application/json', @config.get(:mime_json)
  end

  def test_second_env
    @config.env = :second_env
    assert_equal 'http://github.com/thoom', @config.get(:url)
    assert_equal 'application/json', @config.get(:mime_json)
  end

  def test_default_value
    assert_equal 'default_val', @config.get(:missing_key, 'default_val')
  end

  def test_add_value
    @config.set(:new_key, 'new value')
    assert_equal 'new value', @config.get(:new_key)

    @config.env = :second_env
    assert_equal 'new value', @config.get(:new_key)
  end

  def test_missing_raises
    assert_raises(Thoom::ConfigError) { @config.get(:missing_raises) }
  end
end
