require 'rubygems'
require 'dm-core'
$LOAD_PATH << Pathname(__FILE__).dirname.parent.expand_path + 'lib'

# just define a empty abstract store
module ActionController
  module Session
    class AbstractStore 
      def initialize(app, options = {})
      end
    end
  end
end

class Session
  
  include ::DataMapper::Resource

  property :session_id, String, :key => true

end
