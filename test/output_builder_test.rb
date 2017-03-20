require 'byebug' if ENV['DEBUG']
require 'minitest/autorun'
require_relative '../lib/output_builder'

# Only a simple test of the output builder class
class TestOutputBuilder < Minitest::Test
  def test_simple
    output = Thoom::SimpleOutputBuilder.new
    assert_equal :default, output.colors[:title_color]
  end
  
  def test_default
    output = Thoom::DefaultOutputBuilder.new
    assert_equal 16, output.colors.length
  end
end
