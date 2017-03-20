require 'base64'

require 'byebug' if ENV['DEBUG']
require 'minitest/autorun'
require 'webmock/minitest'
require_relative '../lib/rest_up'

CLIENT_CERT = '-----BEGIN CERTIFICATE-----
MIIC/jCCAeYCAQIwDQYJKoZIhvcNAQELBQAwRTELMAkGA1UEBhMCQVUxEzARBgNV
BAgMClNvbWUtU3RhdGUxITAfBgNVBAoMGEludGVybmV0IFdpZGdpdHMgUHR5IEx0
ZDAeFw0xNzAzMjAwMDM0NDVaFw0xNzA0MTkwMDM0NDVaMEUxCzAJBgNVBAYTAkFV
MRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRz
IFB0eSBMdGQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCuyAWJjsSv
HwKAy0Zl1O6rpGfWk9gsWBbpPVHPvvf2spXd+LhrPfZ0SH8/Lxst82DMGTXTLtLC
COsQGnm6bMrFEwlHpVvGmEo24sa5HyRhGWhsbnP0DML9CtLrdrDQaluZxEOBBWAl
AYkk1OtJIlyXaKywFTwtt+KdU6R1R29Elnn3Mzdy+9s2pAuyGfHOFQo+zmaUWjq3
bzumfXkggSXTH46KCVk5vThnA48E3lxudOLEkuH5OM27UthbfU7HxwlmHm8lXeE1
EyMc3RL4HC2YECRLj3V78VKc+tBQfLS/TkFCUALbIYYg+zZ/gaOW3Rhf+sGjXyot
OQkHmjb0GVDxAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAM8/mnngdWaAi1xbywuL
D/ifvbvRbeE/YGmR968lVWC5UxnOuHHGPdavbLr/cMVyAeuNFCz+TcmSfIkLQnE3
A2iRrEDoTLPXlXy0EOgMf+4RtOzG7v74CRPwPVPBe99T7PIWVQZJMQgi7aM7ypxK
VP/eVhO73DQT2fBqegdXCujBHvZKzOH3FC7UhyZkKiMnzFgVyUdIA7EwKwSwBj1j
dNjfpsSPBdeiiRI4xBIPw9Pwt0bSpE9SRe+iqfc+mrdpFbQFjLLeGfKGbzPw2IFB
WRvWtj6hcU0X0y9WrdRUUKmAAmfAn6NV8dSys6xL0N3WNspEayl+HNglUm243fgg
P1c=
-----END CERTIFICATE-----
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEArsgFiY7Erx8CgMtGZdTuq6Rn1pPYLFgW6T1Rz7739rKV3fi4
az32dEh/Py8bLfNgzBk10y7SwgjrEBp5umzKxRMJR6VbxphKNuLGuR8kYRlobG5z
9AzC/QrS63aw0GpbmcRDgQVgJQGJJNTrSSJcl2issBU8LbfinVOkdUdvRJZ59zM3
cvvbNqQLshnxzhUKPs5mlFo6t287pn15IIEl0x+OiglZOb04ZwOPBN5cbnTixJLh
+TjNu1LYW31Ox8cJZh5vJV3hNRMjHN0S+BwtmBAkS491e/FSnPrQUHy0v05BQlAC
2yGGIPs2f4Gjlt0YX/rBo18qLTkJB5o29BlQ8QIDAQABAoIBAEzHxdb2BuU/ZCQc
KGLXtbllUdBrxk1ErVvs+iGfLOMM9NU8TBegcsIGjw+8q931ypIeiQyqxx9CN7Et
UEhbPoBwqmT0+Wo2wHN4EACG875MIRlxNDMD4Cy1Mo8J5wbHklHsbBMjv2bCU/MA
LhREqhRBgYsg6PzUiRLACcETjoe8MJABTYQTBhJ16Pk046zP+DXdzPu36FnLDVhy
j9JU0nlu6QDTkUq1Zv6J5e1z57vkVOe8oJuvyomyG/2ziCUBoibIU0kyLoOMTTVi
shlmrQUAhmJPugzYop2a49Qj/LRIEc1dCIPTfZ4nRGq0f5AzLU9tUt54F925tQfJ
D1psAaECgYEA5NGKEKDAx/oATBvVIWnzgsr6iq/VJfUpa1SFvB/kjjtDUA861qsS
niQLI9557HlF/HaSgwG07lUUuCfrmt3Og42Dt4apWk+/WLOy74Xb/lo+aUWz5qFs
UOCCeB1YOzdCZ8kZUhHpQonOvpih71d6iSw1g/0L2wu69gaJgZoETY0CgYEAw4sw
xr10TXdTrBqHfvqWHJKFx6QZM/jtmGBWhjzXGB2VVedNLxzOsFmMTkZMWOlbNcxg
3RZ9wMMfXMHqiPX+peObv4UwoD2HSUjH54yQZ3oqDRagfoplkc1Hw4jYUPtMFZsn
4KuprV9lNj5l+HXr+ve1W2wA14kNXuABDGQivfUCgYA8bEDDJ1AA/rl5X5gmXK4b
CbKjUM8+WMD5QLaX+OwHywp5Z6wn58Dg1a/DZwpXMacThdQmmBrJHNp9zrzehlf0
UThJDFxIJurmZ32G1phDUF1Ou0NIUbQin0aUpVsZN/xnH6l6DJTGJ1Ha7r9ETptj
AbOYCQhKbYyPTyacfKlKOQKBgQCLBS0zTkQeQwSwqdfE9eC9BYqo6cilQ4efunYp
T53YXkfqX9xm70Me6zst9xqWZ6lZ8Si4ZiIXZmGor5DPuJxHUi9LlSSB99xzxJOi
0jNj7d1xmrGV5UzawKgRovuvb0mjXsCWIVUrllO9odUbNLMFpRBBo+JhWeWwmu8D
4Tk19QKBgFjx//9+Mz+XlMwHA8g+jVRba0PSPRp2W4MyjAzHWZeJ/1JyA9d6YLn+
cmqFENP4evjroplLtt+SQJk5xaiEyW+BsnZNkEzRiHpqhm4OCTbotyQyxTbR9g4P
ASSPbJlaDNnYBc/lxHPOcpHsXJF0R7DZlOzwbY8dBMt7pKoWtEev
-----END RSA PRIVATE KEY-----'.freeze

# Test the restup class
class TestRestUp < Minitest::Test
  def test_url
    restup = Thoom::RestUp.new(Thoom::HashConfig.new(url: 'http://ex.io'))

    # Standard case
    restup.endpoint = '/test/'
    assert_equal 'http://ex.io/test/', restup.url

    # If the endpoint starts with http, don't append the config's URL
    restup.endpoint = 'http://someotherdomain.com/test/'
    assert_equal 'http://someotherdomain.com/test/', restup.url
  end

  def test_invalid_url
    restup = Thoom::RestUp.new(Thoom::HashConfig.new(url: 'invalid_url'))

    restup.endpoint = '/foo'
    error = assert_raises(Thoom::RestUpError) { restup.request }
    assert_equal 'Invalid URL', error.message
  end

  def test_basic_auth
    config = Thoom::HashConfig.new(
      user: 'joe', pass: 'abc1234', url: 'http://ex.io'
    )

    restup = Thoom::RestUp.new(config)
    restup.method = 'get'
    restup.endpoint = '/foo'

    encoded = Base64.urlsafe_encode64('joe:abc1234')

    request = restup.request
    assert_equal "Basic #{encoded}", request.each_header.to_h['authorization']
  end

  def test_invalid_method
    restup = Thoom::RestUp.new(Thoom::HashConfig.new(url: 'http://ex.io'))

    error = assert_raises(Thoom::RestUpError) { restup.method = 'foobar' }
    assert_equal 'Invalid Method', error.message
  end

  def test_xmethod
    config = Thoom::HashConfig.new(url: 'http://ex.io', xmethods: ['FooBar'])
    restup = Thoom::RestUp.new(config)
    restup.method = 'foobar'

    # If the method is an allowed xmethod,
    # then change it to post and add a method override header
    assert_equal 'post', restup.method
    assert_equal 'FOOBAR', restup.headers['x-http-method-override']

    # If the method is not an allowed xmethod, it should raise an error
    error = assert_raises(Thoom::RestUpError) { restup.method = 'fezbaz' }
    assert_equal 'Invalid Method', error.message
  end

  def test_xmethod_error
    # xmethods should always be an array
    config = Thoom::HashConfig.new(url: 'http://ex.io', xmethods: 'FooBar')
    restup = Thoom::RestUp.new(config)

    error = assert_raises(Thoom::RestUpError) { restup.method = 'foobar' }
    assert_equal 'Invalid xmethods configuration', error.message
  end

  def test_client_cert
    config = Thoom::HashConfig.new(url: 'https://ex.io', cert: CLIENT_CERT)
    restup = Thoom::RestUp.new(config)

    restup.method = 'get'
    restup.endpoint = '/api'

    http = restup.http
    assert http.cert
    assert http.key
  end

  def test_client_cert_invalid
    config = Thoom::HashConfig.new(url: 'https://ex.io', cert: 'bad')
    restup = Thoom::RestUp.new(config)

    restup.method = 'get'
    restup.endpoint = '/api'

    error = assert_raises(Thoom::RestUpError) { restup.http }
    assert_equal 'Invalid client certificate', error.message
  end

  def test_tls
    config = Thoom::HashConfig.new(url: 'https://ex.io')
    restup = Thoom::RestUp.new(config)

    restup.method = 'get'
    restup.endpoint = '/api'

    # Default to verifying SSL
    http = restup.http
    assert_equal true, http.use_ssl?
    assert_equal OpenSSL::SSL::VERIFY_PEER, http.verify_mode
  end

  def test_tls_verify_off
    config = Thoom::HashConfig.new(url: 'https://ex.io', tls_verify: false)
    restup = Thoom::RestUp.new(config)

    restup.method = 'get'
    restup.endpoint = '/api'

    http = restup.http
    assert_equal true, http.use_ssl?
    assert_equal OpenSSL::SSL::VERIFY_NONE, http.verify_mode
  end

  def test_body_empty
    config = Thoom::HashConfig.new(url: 'http://ex.io')
    restup = Thoom::RestUp.new(config)

    restup.method = 'post'
    restup.endpoint = '/api'

    # If nothing is passed, content-length should be zero
    request = restup.request
    assert_equal 0, request.each_header.to_h['content-length'].to_i
  end

  def test_body
    config = Thoom::HashConfig.new(url: 'http://ex.io')
    restup = Thoom::RestUp.new(config)

    body = 'This is a test body'

    restup.method = 'post'
    restup.endpoint = '/api'
    restup.data = body

    # Make sure the lengths match
    request = restup.request
    assert_equal body, request.body
    assert_equal body.length, request.each_header.to_h['content-length'].to_i
  end

  def test_headers
    config = Thoom::HashConfig.new(
      url: 'http://ex.io', headers: { 'X-Random' => 'abc123' }
    )

    restup = Thoom::RestUp.new(config)
    assert_equal 'abc123', restup.headers[:'X-Random']

    # Make sure that when merging, the new overwrites the old
    restup.headers = { 'X-Random' => 'def456', 'X-Random2' => 'ghi789' }
    assert_equal 'def456', restup.headers[:'X-Random']

    # New headers are added to the hash
    assert_equal 'ghi789', restup.headers[:'X-Random2']
  end

  def test_request_headers
    config = Thoom::HashConfig.new(
      url: 'http://ex.io', headers: { 'X-Random' => 'abc123' }
    )

    restup = Thoom::RestUp.new(config)
    restup.method = 'get'
    restup.endpoint = 'http://ex.io/api'

    # Headers added to the request
    request = restup.request
    assert_equal 'abc123', request.each_header.to_h['x-random']
  end
end
