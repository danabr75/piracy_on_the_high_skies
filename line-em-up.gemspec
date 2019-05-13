# Ruby 2.4.4

Gem::Specification.new do |s|
  s.name        = 'line-em-up'
  s.version     = '2.0.2'
  s.date        = '2018-05-24'
  s.summary     = "Vertical Scrolling Shooter"
  s.description = "A simple gosu test with a vertical-scrolling shooter"
  s.authors     = ["Ben Dana"]
  s.email       = 'benrdana@gmail.com'
  s.executables   = ["line-em-up.sh"]
  # s.files       = Dir['gosu-test/lib/**/*'] + Dir['gosu-test/media/**/*'] + Dir['gosu-test/*']
  s.files       = Dir['vendors/lib/**/*'] + Dir['vendors/lib/*'] + Dir['line-em-up/lib/**/*'] + Dir['line-em-up/media/**/*'] + Dir['line-em-up/models/**/*'] + Dir['line-em-up/*'] + Dir['menu_launcher.rb']
  s.homepage    = 'https://github.com/danabr75/line-em-up'
  s.license       = 'MIT'
  # s.add_development_dependency 'gosu', '0.13.3'
  # s.add_development_dependency 'opengl', '0.10.0'
  s.add_development_dependency 'ocra', '1.3.10'
  s.add_development_dependency 'pry', '0.12.2'
  s.add_runtime_dependency 'gosu', '0.14.5'
  s.add_runtime_dependency 'opengl', '0.10.0'
  s.add_runtime_dependency 'luit', '0.1.4'
  s.add_runtime_dependency 'glu', '8.3.0'
  s.add_runtime_dependency 'glut', '8.3.0'
    
    

end