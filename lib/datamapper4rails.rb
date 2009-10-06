require 'rails_datamapper'
require 'rack-datamapper'
require 'datamapper4rails/datamapper_store'

# keep this here until rails_datamapper has it included
module DataMapper
  module Validate
    class ValidationErrors
      def count
        size
      end
    end
  end
end
