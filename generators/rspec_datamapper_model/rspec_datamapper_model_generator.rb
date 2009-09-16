require 'rails_generator/generators/components/model/model_generator'
require 'active_record'
require File.dirname(__FILE__) + '/../overlay'

class RspecDatamapperModelGenerator < RspecModelGenerator

  def manifest
    overlay_dirs << File.join(self.class.lookup("datamapper_model").path, 'templates')
    overlay_dirs << File.join(self.class.lookup("rspec_model").path, 'templates')
    super
  end

end
