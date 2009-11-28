# inspired by http://www.rowtheboat.com/archives/32
###################################################

# this pulls in rails_datamapper and rack_datamapper
gem 'datamapper4rails'

# assume sqlite3 to be database
gem 'do_sqlite3'

# assume you want to have validations and timestamps in your models
gem 'dm-validations'
gem 'dm-timestamps'
gem 'dm-migrations'
gem 'dm-serializer' # to allow xml interface to work
gem 'dm-core'

# get all datamapper related gems
gem 'addressable', :lib => 'addressable/uri'

# assume you prefer rspec over unit tests
gem 'rspec', :lib => false
gem 'rspec-rails', :lib => false

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
require 'datamapper4rails/datamapper_store'
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
echo "java gems like the dataobjects drivers (do_sqlite3, etc) !!"
echo

mvn --version
if [ $? -ne 0 ] ; then

        echo "please install maven >= 2.0.9 from maven.apache.org"
        exit -1
fi

mvn de.saumya.mojo:rails-maven-plugin:gems-install de.saumya.mojo:rails-maven-plugin:rails-freeze-gems de.saumya.mojo:rails-maven-plugin:gems-install -Djruby.fork=false

echo
echo "you can run rails with (no need to install jruby !!)"
echo
echo "\tmvn de.saumya.mojo:rails-maven-plugin:server -Djruby.fork=false"
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
logger.info "if you want to run jruby please run again after uninstalling"
logger.info "the native extension of do_sqlite3"
logger.info "\truby -S gem uninstall do_sqlite3"
logger.info "\tjruby -S rake gems:install"
logger.info "rake gems:unpack does NOT work with jruby due to a bug in rail <=2.3.4"
logger.info "you can try the prepare-jruby.sh script and see if this works for you"
logger.info 
