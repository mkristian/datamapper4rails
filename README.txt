= datamapper4rails

* http://datamapper4rail.rubyforge.org
* http://github.org/mkristian/datamapper4rails

== DESCRIPTION:

collection of datamapper related extensions. mostly needed to run within rails. the restful transactions is around filter for rails actions if needed to control such transaction on per action base otherwise use the rack extension from rack-datamapper. datamapper store is a session store for rails which uses datamapper as persistent layer and is just a wrapper around the datamapper session store from rack-datamapper. the generators produces datamapper models for your rails application.

== FEATURES/PROBLEMS:

* the generators introduce an "overlay" of templates. with that a generator can reuse the generator code and just replace one or more templates. i.e. datamapper_model just replaces the model.rb template to produce model using datamapper.

== SYNOPSIS:

=== restful transaction

wraps all modifying requests (POST, PUT, DELETE) into a transaction. any error/exception as well render of a page will rollback the transaction. typically if a POST, PUT or DELETE succeeds then a redirect gets send back to browser.

credits of the main idea goes to http://www.redhillonrails.org

is implemented as around filter in rails and gets prepend to the filters of the action_controller of rails

  require 'datamapper4rails/restful_transations'

=== restful transactions, transactions or identity_maps from rack-datamapper

inside rails add something like this to your config

config.middleware.use 'DataMapper::IdentityMaps'
config.middleware.use 'DataMapper::RestfulTransactions'

or add the repository name to it if you want something else then :default

config.middleware.use 'DataMapper::IdentityMaps', :ldap
config.middleware.use 'DataMapper::RestfulTransactions', :users


=== datamapper session store

add in your config/initializers/session.rb

    ActionController::Base.session_store = :datamapper_store

in case you need a memory cache for your sessions on top of it add the following. but be aware that there is no cleanup of the memory session.

  ActionController::Base.session = { :cache => true }

=== generators for datamapper models

IMPORTANT: datamapper_scaffold generate valid application code but the test do NOT run due to missing fixtures with datamapper. the rspec version works well though.

* datamapper-install: rake task for datamapper with automigrate, autoupgrade and migrate
* datamapper_model
* datamapper_rspec_model
* datamapper_scaffold
* datamapper_rspec_scaffold

the last  four generators follow the parameters of  the underlying generator:
generator_name model_name [[attribute_name:attribute_type] ...]

to use the overlay write the generator like this

class MyModelGenerator < ModelGenerator
  def manifest
    overlay_dirs.add_generator("model")
    super
  end
end

and put whatever templates you want to overwrite in your templates directory, i.e. all your models need to have nice to_s methods.

=== patch for the rspec-rails gem

add a file like spec/support/datamapper with

require 'datamapper4rails/rspec'

this allows rspec to stub_model with datamapper

=== restful adapter

DEPRECATED
this comes partly from dm-ldap-adapter and partly from dm-more/adapter/rest_adapter. the restful adapter allows to Create, Retrieve, Update and Delete resources via a restful service.

== rails template

there is a rails template 'datamapper_rails_templates.rb' in root of the gem - do not know where and how to pack it. the latest I keep on 'github.org/jeremy/rails-templates'

=== to test the template there is helper class

task :integration_tests => [:install] do
  require 'datamapper4rails/integration_test'
  Datamapper4Rails::IntegrationTest.new do |t|
    t.rails_template = 'my_template.rb'
    t.directory = 'tmp' # defaults to tmp and is also the generated application name
    t.generate "datamapper_model role name:string"
    t.generate "datamapper_scaffold domain name:string"
    t.generate "datamapper_rspec_model user name:string"
    t.generate "datamapper_rspec_scaffold group name:string"
  end
end

== more examples 

just run 'rake integration' and have a look at the sample rails application in 'tmp'

== jruby

at the time of writing there is a bug/restriction in rails which prevents unpacked gems with java extension or version number postfixed with '-java' to work.

if you are familiar with maven (maven.apache.org) you can use the maven plugin from github.org/mkristian/rails-maven-plugin to freeze rails gems and patch it in place

mvn de.saumya.mojo:rails-maven-plugin:rails-freeze-gems

the 'rake integration_tests' does not work due to the fact that generating rails with a template falls back to native ruby for certain tasks which will fail due to missing (java) gems.

same is true for using the rails template. in case you want to use a rails template directly with jruby consider the rails-maven-plugin which can setup a mavenized rails application with the help of rails templates.

== REQUIREMENTS:

* rails_datamapper, rack-datamapper

== INSTALL:

* sudo gem install datamapper4rails

== LICENSE:

(The MIT License)

Copyright (c) 2009 Kristian Meier

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
