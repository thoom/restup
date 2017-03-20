Gem::Specification.new do |s|
  s.name         = 'restclient'
  s.version      = '0.14.4'
  s.date         = '2017-03-20'
  s.summary      = 'Thoom RestClient: A simple REST consumer'
  s.description  = 'A class and executable for interacting with RESTful web services'
  s.authors      = ['Z.d. Peacock']
  s.email        = 'zdp@thoomtech.com'
  s.has_rdoc = false
  s.require_path = 'lib'
  s.files        = %w( README.md LICENSE )
  s.files        += Dir.glob('lib/**/*')
  s.files        += Dir.glob('bin/**/*')
  s.homepage     = 'http://github.com/thoom/restclient'
  s.license      = 'MIT'

  s.post_install_message = <<-MESSAGE
!    The 'restclient' gem has been deprecated and has been replaced by 'restup'.
!    See: https://rubygems.org/gems/restup
!    And: https://github.com/thoom/restup
MESSAGE

  s.add_runtime_dependency 'paint', '~>1.0'

  s.executables << 'restclient'
end
