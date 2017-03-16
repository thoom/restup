Gem::Specification.new do |s|
  s.name         = 'restup'
  s.version      = '1.0'
  s.date         = '2017-03-15'
  s.summary      = 'Thoom RestUp: A simple REST client'
  s.description  = 'A class and executable for interacting with RESTful web services'
  s.authors      = ['Z.d. Peacock']
  s.email        = 'zdp@thoomtech.com'
  s.has_rdoc = false
  s.require_path = 'lib'
  s.files        = %w( README.md LICENSE )
  s.files        += Dir.glob('lib/**/*')
  s.files        += Dir.glob('bin/**/*')
  s.homepage     = 'http://github.com/thoom/restup'
  s.license      = 'MIT'

  s.add_runtime_dependency 'paint', '~>1.0'

  s.executables << 'restup'
end
