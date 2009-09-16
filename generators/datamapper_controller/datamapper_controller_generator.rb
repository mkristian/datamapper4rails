require File.dirname(__FILE__) + '/../overlay'

# this controller is just for completeness but does not offer
# any further functionality to the underlying controller
class DatamapperControllerGenerator < ControllerGenerator

  def manifest
    overlay_dirs << File.join(self.class.lookup("controller").path, 'templates')
    super
  end

end
