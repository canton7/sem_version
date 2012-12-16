$LOAD_PATH.unshift(File.dirname(File.expand_path(__FILE__)))
require 'lib/sem_version'

Gem::Specification.new do |s|
  s.name = 'sem_version'
  s.version = SemVersion::VERSION
  s.summary = 'SemVersion: Semantic version parsing and comparison. See http://semver.org/'
  s.description = 'Semantic Version parsing, comparison, and constraint checking utility, as specified by http://semver.org/'
  s.homepage = 'https://github.com/canton7/sem_version'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Antony Male']
  s.email = 'antony dot mail at gmail'
  s.required_ruby_version = '>= 1.9.2'

  s.files = 'lib/sem_version.rb'
end
