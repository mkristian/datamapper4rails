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
 
  property :updated_at, DateTime

  property :data, Text, :nullable => false, :default => ::Base64.encode64(Marshal.dump({}))
  
  def data=(data)
    attribute_set(:data, ::Base64.encode64(Marshal.dump(data)))
  end
  
  def data
    Marshal.load(::Base64.decode64(attribute_get(:data)))
  end 
end

DataMapper.setup(:default, {:adapter  => 'in_memory'})
