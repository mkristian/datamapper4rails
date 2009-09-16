#require 'datamapper4rails/database_config'
require 'rails_datamapper'

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
