require File.dirname(__FILE__) + "/lib/constants"

Gem::Specification.new do |s|
  s.name         = 'restup'
  s.version      = Thoom::Constants::VERSION
  s.date         = '2017-03-20'
  s.summary      = 'Thoom RestUp: A simple REST client'
  s.description  = 'A class and executable for interacting with RESTful web services'
  s.authors      = ['Z.d. Peacock']
  s.email        = 'zdp@thoomtech.com'
  s.require_path = 'lib'
  s.homepage     = 'http://github.com/thoom/restup'
  s.license      = 'MIT'

  s.files        = Dir.glob('lib/**/*')
  s.files        += Dir.glob('bin/**/*')
  
  s.extra_rdoc_files = %w( README.md CHANGELOG.md LICENSE )

  s.add_runtime_dependency 'paint', '~>2.0'
  s.required_ruby_version = '>= 2.0'

  s.executables << 'restup'
end
