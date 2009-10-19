# inspired by http://www.rowtheboat.com/archives/32
###################################################

# get all datamapper related gems
gem 'addressable', :lib => 'addressable/uri'

# assume sqlite3 to be database
gem 'do_sqlite3'

# assume you want to have validations and timestamps in your models
gem 'dm-validations'
gem 'dm-timestamps'
gem 'dm-migrations'
gem 'dm-serializer' # to allow xml interface to work

# assume you prefer rspec over unit tests
gem 'rspec', :lib => false
gem 'rspec-rails', :lib => false

# this pulls in rails_datamapper and rack_datamapper
gem 'datamapper4rails'

# install all gems
rake 'gems:install'

# install specs rake tasks
generate('rspec', '-f')

# install datamapper rake tasks
generate('datamapper_install')

# fix config files to work with datamapper instead of active_record
environment ''
environment 'config.frameworks -= [ :active_record ]'
environment '# deactive active_record'
gsub_file 'spec/spec_helper.rb', /^\s*config[.]/, '  #\0'
gsub_file 'test/test_helper.rb', /^[^#]*fixtures/, '  #\0'

file 'spec/support/datamapper.rb', <<-CODE
require 'datamapper4rails/rspec'
CODE

# add middleware
def middleware(name)
  log 'middleware', name
  environment "config.middleware.use '#{name}'"
end

environment ''
middleware 'DataMapper::RestfulTransactions'
middleware 'DataMapper::IdentityMaps'
middleware 'Rack::Deflater'
environment '# add middleware'

# init a session store
initializer 'datamapper_store.rb', <<-CODE
# init a session store which uses a memory cache and a persistent store
# cleanup can be a problem. jruby uses soft-references for the cache so
# memory cleanup with jruby is not a problem.
require 'ixtlan/session'
ActionController::Base.session_store = :datamapper_store
ActionController::Base.session = {
  :cache       => true,
}
CODE

# gzip fix for jruby
initializer 'monkey_patches.rb', <<-CODE
if RUBY_PLATFORM =~ /java/
  require 'zlib'
  class Zlib::GzipWriter
    def <<(arg)
      write(arg)
    end
  end
end
CODE

file 'prepare_jruby.sh', <<-CODE
#!/bin/bash

echo
echo "shall freeze rails and fix a bug which prevents rails to use certain"
echo "java gems like the dataobjects drivers !!"
echo

mvn --version
if [ $? -ne 0 ] ; then

        echo "please install maven >= 2.0.9 from maven.apache.org"
        exit -1
fi

mvn de.saumya.mojo:rails-maven-plugin:rails-freeze-gems de.saumya.mojo:rails-maven-plugin:gems-install

echo
echo "you can run rails with (no need to install jruby !!)"
echo
echo "\tmvn de.saumya.mojo:rails-maven-plugin:server"
echo
echo "more info on"
echo "\thttp://github.org/mkristian/rails-maven-plugin"
echo
echo
CODE

rake 'db:sessions:create'

logger.info 
logger.info 
logger.info "info mavenized rails application"
logger.info "\thttp://github.org/mkristian/rails-maven-plugin"
logger.info 
logger.info 
