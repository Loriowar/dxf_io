# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dxf_io/version'

Gem::Specification.new do |spec|
  spec.name          = 'dxf_io'
  spec.version       = DxfIO::VERSION
  spec.authors       = ['Ivan Zabrovskiy']
  spec.email         = ['loriowar@gmail.com']

  spec.summary       = %q{Gem for read and write DXF files}
  spec.description   =  <<-STRING
                          Gem for read and write DXF files.
                          Gem based on "ruby-dxf-reader" from https://github.com/jimfoltz/ruby-dxf-reader.
                          It support DXF files comes from AutoCAD 2008 (http://images.autodesk.com/adsk/files/acad_dxf0.pdf).
                        STRING
  spec.homepage      = 'https://github.com/Loriowar/dxf_io'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_dependency 'activesupport', '>= 3.2'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
end
