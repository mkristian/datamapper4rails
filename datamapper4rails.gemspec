# create by maven - leave it as is
Gem::Specification.new do |s|
  s.name = 'datamapper4rails'
  s.version = '0.5.0'

  s.summary = 'collection of datamapper related extensions'
  s.description = 'collection of datamapper related extensions. mostly needed to run within rails. the restful transactions is around filter for rails actions if needed to control such transaction on per action base otherwise use the rack extension from rack-datamapper. datamapper store is a session store for rails which uses datamapper as persistent layer and is just a wrapper around the datamapper session store from rack-datamapper. the generators produces datamapper models for your rails application.'
  s.homepage = 'http://datamapper4rail.rubyforge.org'

  s.authors = ['mkristian']
  s.email = ['m.kristian@web.de']

  s.date = '2010-06-20'
  s.rubygems_version = '1.3.5'
  s.rubyforge_project = 'datamapper4rail'
  s.extra_rdoc_files = ['History.txt','Manifest.txt','README.txt']
  s.rdoc_options = ['--main','README.txt']
  s.require_paths = ['lib']
  s.files = Dir['lib/**/*']
  s.files += Dir['generators/**/*']
  s.files += Dir['spec/**/*']
  s.test_files += Dir['spec/**/*_spec.rb']
  s.add_dependency 'rack-datamapper', '~> 0.3.0'
  s.add_development_dependency 'rspec', '~> 1.3.0'
end