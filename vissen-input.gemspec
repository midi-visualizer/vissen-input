
lib = File.expand_path('../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vissen/input/version'

Gem::Specification.new do |spec|
  spec.name          = 'vissen-input'
  spec.version       = Vissen::Input::VERSION
  spec.authors       = ['Sebastian Lindberg']
  spec.email         = ['seb.lindberg@gmail.com']
  
  spec.summary       = 'The input side of the vissen system.'
  spec.description   = 'This gem implements the input messages and message ' \
                       'matching engine used in the vissen project.'
  spec.homepage      = 'https://github.com/midi-visualizer/vissen-input'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
