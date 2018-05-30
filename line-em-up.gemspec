# Ruby 2.4.4

Gem::Specification.new do |s|
  s.name        = 'line-em-up'
  s.version     = '0.3.6'
  s.date        = '2018-05-24'
  s.summary     = "Vertical Scrolling Shooter"
  s.description = "A simple gosu test with a vertical-scrolling shooter"
  s.authors     = ["Ben Dana"]
  s.email       = 'benrdana@gmail.com'
  s.executables   = ["line-em-up.sh"]
  # s.files       = Dir['gosu-test/lib/**/*'] + Dir['gosu-test/media/**/*'] + Dir['gosu-test/*']
  s.files       = Dir['line-em-up/lib/**/*'] + Dir['line-em-up/media/**/*'] + Dir['line-em-up/models/**/*'] + Dir['line-em-up/*'] + Dir['menu_launcher.rb']
  s.homepage    = 'https://github.com/danabr75/line-em-up'
  s.license       = 'MIT'
  # s.add_development_dependency 'gosu', '0.13.3'
  # s.add_development_dependency 'opengl', '0.10.0'
  s.add_development_dependency 'ocra', '1.3.10'
  s.add_runtime_dependency 'gosu', '0.13.3'
  s.add_runtime_dependency 'danabr75-opengl', '0.10.0'
end