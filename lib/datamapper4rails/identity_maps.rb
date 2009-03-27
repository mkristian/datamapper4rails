module Datamapper4rails
  module IdentityMaps

    module Base
      def self.included(base)
        base.prepend_around_filter(IdentityMapFilter)
      end
    end
  
    class IdentityMapFilter

      def self.filter(controller)
        DataMapper.repository(:default) do |*block_args|
          if block_given? 
            yield (*block_args)
          end
        end
      end
    end
  end
end

::ActionController::Base.send(:include, Datamapper4rails::IdentityMaps::Base)
