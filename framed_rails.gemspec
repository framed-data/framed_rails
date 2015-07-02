# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'framed/version'

Gem::Specification.new do |s|
  s.name = "framed_rails"
  s.version = Framed::VERSION::STRING
  s.required_ruby_version = '>= 1.8.7'
  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = [ "Jeremy Dunck" ]
  s.date = Time.now.strftime('%Y-%m-%d')
  s.licenses    = ['MIT']
  s.description = <<-EOS
TK
EOS
  s.email = "support@framed.io"
  s.executables = [ ]
  s.extra_rdoc_files = [
    "CHANGELOG",
    "LICENSE",
    "README.md"
  ]

  file_list = `git ls-files`.split
  s.files = file_list

  s.homepage = "http://www.github.com/framed-data/framed_rails"
  s.require_paths = ["lib"]
  s.rubygems_version = Gem::VERSION
  s.summary = "Framed.io data collector"

  # s.add_development_dependency 'rake', '10.1.0'

  # FIXME: RUBY_VERSION, RUBY_PLATFORM, RUBY_ENGINE
end
