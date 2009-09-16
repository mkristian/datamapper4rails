require File.dirname(__FILE__) + '/../overlay'
require File.dirname(__FILE__) + '/../rspec_default_values'

class RspecDatamapperScaffoldGenerator < RspecScaffoldGenerator

  def manifest
    overlay_dirs << File.join(self.class.lookup("scaffold").path, 'templates')
    overlay_dirs << File.join(self.class.lookup("rspec_scaffold").path, 'templates')
    overlay_dirs << File.join(self.class.lookup("datamapper_model").path, 'templates')
    overlay_dirs << File.join(self.class.lookup("rspec_model").path, 'templates')
    overlay_dirs << source_root

    super
  end

end
