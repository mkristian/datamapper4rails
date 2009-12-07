require 'rubygems'
require 'dm-core'
require 'base64'
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

  property :raw_data, Text, :required => true, :default => ::Base64.encode64(Marshal.dump({}))
  
  def data=(data)
    attribute_set(:raw_data, ::Base64.encode64(Marshal.dump(data)))
  end
  
  def data
    Marshal.load(::Base64.decode64(attribute_get(:raw_data)))
  end 
end

DataMapper.setup(:default, {:adapter  => 'in_memory'})
