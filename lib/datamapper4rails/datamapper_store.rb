require 'dm-core'
require 'rack_datamapper/session/datamapper'
begin
  require 'securerandom'
rescue LoadError
end

module ActionController
  module Session
    class DatamapperStore < AbstractStore
      SecureRandom =
        if defined?(::SecureRandom)
          # Use Ruby's SecureRandom library if available.
          ::SecureRandom
        else
          # try if there is active support around ;-)
          require 'active_support'
          ::ActiveSupport::SecureRandom
        end

      def initialize(app, options = {})
        super

        id_generator = Proc.new do
          SecureRandom.hex(16)
        end
        @store = ::DataMapper::Session::Abstract::Store.new(app, options, id_generator)
        @options = options
      end

      private
      def get_session(env, sid)
        @store.get_session(env, sid)
      end

      def set_session(env, sid, session_data)
        @store.set_session(env, sid, session_data, @options)
      end
    end
  end
end
