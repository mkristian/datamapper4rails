= datamapper4rails

* http://datamapper4rail.rubyforge.org

== DESCRIPTION:

collection of datamapper related extensions. mostly needed to run within rails. the restful transactions is around filter for rails. the restful adapter can be outside of rails. datamapper store is a session store for rails which uses datamapper as persistent layer. the generators produces datamapper models for your rails application. quite a few things are "stolen" from dm-more/rails_datamapper. a lot of things do not work there and patches are still in process to be applied so until dm-more/rails_datamapper catches up, ut I hope these two project merge someday again.

== FEATURES/PROBLEMS:

* restful adapter does handle associations partially and does not handle collections

== SYNOPSIS:

=== restful transaction

wraps all modifying requests (POST, PUT, DELETE) into a transaction. any error/exception as well render of a page will rollback the transaction. typically if a POST, PUT or DELETE succeeds then a redirect gets send back to browser.

credits of the main idea goes to http://www.redhillonrails.org

is implemented as around filter in rails and gets prepend to the filters of the action_controller of rails

  require 'datamapper4rails/restful_transations

=== datamapper session store

this is just the datamapper compaign to the activerecord_store.

in config/environment.rb add

  config.action_controller.session_store = :datamapper_store

in case you need a memory cache for your sessions add this

  config.action_controller.session = { :cache => true }

=== generators for datamapper models

this is taken from dm-more/rails_datamapper and extended it - to my liking. patches are submitted upstream until they get applied this will remain here.

* dm-install: rake task for datamapper: automigrate, autoupgrade 
* dm_model
* rspec_dm_model

=== database config

this is also taken from dm-more/rails_datamapper and just uses the 
'config/database.yml' to configure a database connection. it also allows to configure multiple repositories for a single environment just nest the config  in such a way:

  development:
    repositories:
      default:
        adapter: sqlite3
        database: db/development.sqlite3
        pool: 5
        timeout: 5000
      users:
        adapter: ldap
        host: localhost
        port: 389
        base: dc=example,dc=com
        bind_name: cn=admin,dc=example,dc=com
        password: secret


=== restful adapter

this comes partly from dm-ldap-adapter and partly from dm-more/adapter/rest_adapter. the restful adapter allows to Create, Retrieve, Update and Delete resources via a restful service.

== REQUIREMENTS:

* datamapper

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
