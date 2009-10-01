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
  p.extra_deps = ['rack_datamapper', 'rails_datamapper']
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

require 'yard'

YARD::Rake::YardocTask.new

# vim: syntax=Ruby
