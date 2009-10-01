# inspired by http://www.rowtheboat.com/archives/32
###################################################

# get all datamapper related gems
gem "addressable", :lib => "addressable/uri"

# assume sqlite3 to be database
gem "do_sqlite3"

# assume you want to have validations and timestamps in your models
gem 'dm-validations'
gem 'dm-timestamps'
gem 'dm-migrations'

# assume you prefer rspec over unit tests
gem "rspec", :lib => false
gem "rspec-rails", :lib => false

# this pulls in rails_datamapper and rack_datamapper
gem "datamapper4rails"

# install all gems
rake "gems:install"

# install specs rake tasks
generate("rspec")

# install datamapper rake tasks
generate("datamapper_install")

# fix config files to work with datamapper instead of active_record
environment "" 
environment "config.frameworks -= [ :active_record ]"
environment "# deactive active_record"
gsub_file 'spec/spec_helper.rb', /^\s*config[.]/, '  #\0'
gsub_file 'test/test_helper.rb', /^[^#]*fixtures/, '  #\0'

# add middleware
def middleware(name)
  log "middleware", name
  environment "config.middleware.use '#{name}'"
end

environment ""
middleware "DataMapper::RestfulTransactions"
middleware "DataMapper::IdentityMaps"
middleware "Rack::Deflater"
environment "# add middleware"


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

rake 'db:sessions:create'
