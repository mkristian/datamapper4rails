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

file 'pom.xml', <<-CODE
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                      http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.example</groupId>
  <artifactId>demo</artifactId>
  <packaging>war</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>rails datamapper demo</name>
  <url>http://github.com/mkristian/rails-templates/blob/master/datamapper.rb</url>
  <pluginRepositories>
    <pluginRepository>
      <id>saumya</id>
      <name>Saumyas Plugins</name>
      <url>http://mojo.saumya.de</url>
    </pluginRepository>
  </pluginRepositories>
  <build>
    <plugins>
      <plugin>
        <groupId>de.saumya.mojo</groupId>
        <artifactId>rails-maven-plugin</artifactId>
	<version>0.3.1</version>
      </plugin>
      <plugin>
        <groupId>de.saumya.mojo</groupId>
        <artifactId>jruby-maven-plugin</artifactId>
	<version>0.3.1</version>
      </plugin>
      <plugin>
        <groupId>de.saumya.mojo</groupId>
        <artifactId>gem-maven-plugin</artifactId>
	<version>0.3.1</version>
      </plugin>
    </plugins>
  </build>
  <properties>
    <jruby.fork>false</jruby.fork>
  </properties>
</project>
CODE

rake 'db:sessions:create'

logger.info 
logger.info 
logger.info "info mavenized rails application"
logger.info "\thttp://github.org/mkristian/rails-maven-plugin"
logger.info 
logger.info "if you want to run jruby please uninstall"
logger.info "the native extension of do_sqlite3 and install the java version"
logger.info "\truby -S gem uninstall do_sqlite3"
logger.info "\tjruby -S rake gems:install"
logger.info 
logger.info "rake gems:unpack does NOT work with jruby due to a bug in rails <=2.3.5"
logger.info "you can try"
logger.info "\tmvn rails:rails-freeze-gems"
logger.info "which patches rails after freezing it"
logger.info 
logger.info 
logger.info
logger.info
logger.info "for dm-core version 0.10.2 there are a lot of deprecated warning but everything works as expected"
logger.info
logger.info
