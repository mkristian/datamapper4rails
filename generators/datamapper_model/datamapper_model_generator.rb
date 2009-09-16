require 'rails_generator/generators/components/model/model_generator'
require 'active_record'
require File.dirname(__FILE__) + '/../overlay'


class DatamapperModelGenerator <ModelGenerator

  def manifest
    overlay_dirs << File.join(self.class.lookup("model").path, 'templates')
    overlay_dirs << source_root
    super
  end

end
