require 'dm-core'

module ActionController
  module Session
    class DatamapperStore < AbstractStore

      def initialize(app, options = {})
        super
        if options.delete(:cache)
          @@cache = {}
        else
          @@cache = nil unless self.class.class_variable_defined? :@@cache
        end
        @@session_class = options.delete(:session_class) || ::DatamapperStore::Session unless (self.class.class_variable_defined? :@@session_class and @@session_class)
      end
      
      private
      def get_session(env, sid)
        sid ||= generate_sid
        session = 
          if @@cache
            @@cache[sid] || @@session_class.get(sid)
          else
            @@session_class.get(sid)
          end
        [sid, session.nil? ? {} : session.data]
      end
      
      def set_session(env, sid, session_data)
        session = 
          if @@cache
            @@cache[sid] || @@session_class.get(sid)
          else
            @@session_class.get(sid)
          end || @@session_class.new(:session_id => sid)
        session.data = session_data || {}
        session.updated_at = Time.now if session.dirty?
        @@cache[sid] = session if @@cache
        session.save
      end
    end
  end
end

module DatamapperStore
  class Session
    
    include ::DataMapper::Resource
    
    def self.name
      "session"
    end
    
    property :session_id, String, :key => true
    
    property :data, Text, :nullable => false, :default => ::Base64.encode64(Marshal.dump({}))
    
    property :updated_at, DateTime, :nullable => true, :index => true
    
    def data=(data)
      attribute_set(:data, ::Base64.encode64(Marshal.dump(data)))
    end

    def data
      Marshal.load(::Base64.decode64(attribute_get(:data)))
    end
  end
end
