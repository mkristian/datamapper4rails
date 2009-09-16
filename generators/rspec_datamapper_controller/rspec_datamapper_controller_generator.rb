require File.dirname(__FILE__) + '/../overlay'

class RspecDatamapperControllerGenerator < RspecControllerGenerator
  def manifest
    overlay_dirs << File.join(self.class.lookup("rspec_controller").path, 'templates')
    super
  end
end
