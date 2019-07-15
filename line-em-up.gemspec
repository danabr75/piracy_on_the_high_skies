# Ruby 2.4.4

Gem::Specification.new do |s|
  s.name        = 'line-em-up'
  s.version     = '3.0.10'
  s.date        = '2018-05-24'
  s.summary     = "2D Video Game"
  s.description = "A Ruby\\Gosu Video Game. Recommended Ruby version 2.4.4"
  s.authors     = ["Ben Dana"]
  s.email       = 'benrdana@gmail.com'
  s.executables   = ["line-em-up.sh"]
  # s.files       = Dir['gosu-test/lib/**/*'] + Dir['gosu-test/media/**/*'] + Dir['gosu-test/*']
  s.files       = 
    Dir['vendors/lib/**/*'] + 
    Dir['vendors/lib/*'] + 
    Dir['line-em-up/lib/**/*'] + 
    Dir['line-em-up/media/**/*'] + 
    Dir['line-em-up/models/**/*'] + 
    Dir['line-em-up/maps/**/*'] + 
    Dir['line-em-up/scripts/**/*'] + 
    Dir['line-em-up/sounds/**/*'] + 
    Dir['line-em-up/dialogues/**/*'] + 
    Dir['line-em-up/vendors/**/*'] + 
    Dir['line-em-up/*'] + 
    Dir['menu_launcher.rb']
  s.homepage    = 'https://github.com/danabr75/line-em-up'
  s.license       = 'MIT'
  # s.add_development_dependency 'ocra', '1.3.10'
  s.add_development_dependency 'pry', '0.12.2'
  s.add_development_dependency 'rmagick', '4.0.0'
  s.add_development_dependency 'benchmark-ips',  '2.7.2'
  s.add_development_dependency 'sourcify',  '0.5.0'
  s.add_runtime_dependency 'gosu', '0.14.5'
  s.add_runtime_dependency 'opengl-bindings', '1.6.9'
  s.add_runtime_dependency 'glut', '8.3.0'
  s.add_runtime_dependency 'parallel',  '1.17.0'
  s.add_runtime_dependency 'ruby-progressbar',  '1.10.1'
  s.add_runtime_dependency 'concurrent-ruby',  '1.1.5'
    
    

end