# -*- ruby -*-

require 'rubygems'

require 'spec'
require 'spec/rake/spectask'

BUILD_DIR = 'target'

desc 'clean up'
task :clean do
  FileUtils.rm_rf(BUILD_DIR)
end

desc 'Package as a gem.'
task :package do
  require 'fileutils'
  gemspec = Dir['*.gemspec'].first
  Kernel.system("#{RUBY} -S gem build #{gemspec}")
  FileUtils.mkdir_p(BUILD_DIR)
  gem = Dir['*.gem'].first
  FileUtils.mv(gem, File.join(BUILD_DIR,"#{gem}"))
  puts File.join(BUILD_DIR,"#{gem}")
end

desc 'Install the package as a gem.'
task :install => [:package] do
  gem = Dir[File.join(BUILD_DIR, '*.gem')].first
  extra = ENV['GEM_HOME'].nil? && ENV['GEM_PATH'].nil? ? "--user-install" : ""
  Kernel.system("#{RUBY} -S gem install --local #{gem} --no-ri --no-rdoc #{extra}")
end

desc 'Run specifications'
Spec::Rake::SpecTask.new(:spec) do |t|
  if File.exists?(File.join('spec','spec.opts'))
    t.spec_opts << '--options' << File.join('spec','spec.opts')
  end
  t.spec_files = Dir.glob(File.join('spec','**','*_spec.rb'))
end

desc 'generate rails using all generators and run the specs'
task :integration_tests => [:spec, :install] do
  require 'datamapper4rails/integration_test'
  Datamapper4Rails::IntegrationTest.new do |t|
    t.generate "datamapper_model role name:string"
    t.generate "datamapper_scaffold domain name:string"
    t.generate "datamapper_rspec_model user name:string"
    t.generate "datamapper_rspec_scaffold group name:string"
  end
end

#require 'yard'

#YARD::Rake::YardocTask.new

# vim: syntax=Ruby
