Gem::Specification.new do |s|
  s.name         = 'restclient'
  s.version      = '0.11.1'
  s.date         = '2015-05-20'
  s.summary      = 'Thoom RestClient: A simple REST consumer'
  s.description  = 'A class and executable for interacting with RESTful web services'
  s.authors      = ['Z.d. Peacock']
  s.email        = 'zdp@thoomtech.com'
  s.has_rdoc	 = false
  s.require_path = 'lib'
  s.files        = %w( README.md LICENSE )
  s.files        += Dir.glob('lib/**/*')
  s.files        += Dir.glob('bin/**/*')
  s.homepage     = 'http://github.com/thoom/restclient'
  s.license      = 'MIT'

  s.add_runtime_dependency 'paint', '~>1.0'

  s.executables << 'restclient'
end
