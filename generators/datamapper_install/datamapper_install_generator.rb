require 'rails_generator/base'

class DatamapperInstallGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.directory 'lib/tasks'
      m.template 'datamapper.rake', 'lib/tasks/datamapper.rake'
    end
  end

end
