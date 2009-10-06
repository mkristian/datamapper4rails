# -*- ruby -*-

require 'rubygems'
require 'hoe'

require 'spec'
require 'spec/rake/spectask'
require 'pathname'

require './lib/datamapper4rails/version.rb'

Hoe.new('datamapper4rails', Datamapper4rails::VERSION) do |p|
  p.rubyforge_name = 'datamapper4rail'
  p.developer('mkristian', 'm.kristian@web.de')
  p.extra_deps = [['rack-datamapper', '~>0.2'], 'rails_datamapper']
  p.remote_rdoc_dir = '' # Release to root
end

desc 'Install the package as a gem.'
task :install => [:clean, :package] do
  gem = Dir['pkg/*.gem'].first
  sh "gem install --local #{gem} --no-ri --no-rdoc"
end

desc 'Run specifications'
Spec::Rake::SpecTask.new(:spec) do |t|
  if File.exists?('spec/spec.opts')
    t.spec_opts << '--options' << 'spec/spec.opts'
  end
  t.spec_files = Pathname.glob('./spec/**/*_spec.rb')
end

desc 'generate rails using all generators and run the specs'
task :integration_tests => [:install] do
  require 'datamapper4rails/integration_test'
  Datamapper4Rails::IntegrationTest.new do |t|
    t.generate "datamapper_model role name:string"
    t.generate "datamapper_scaffold domain name:string"
    t.generate "datamapper_rspec_model user name:string"
    t.generate "datamapper_rspec_scaffold group name:string"
  end
end

require 'yard'

YARD::Rake::YardocTask.new

# vim: syntax=Ruby
