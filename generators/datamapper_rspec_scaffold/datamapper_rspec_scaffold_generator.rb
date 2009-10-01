require 'datamapper4rails/overlay'
require 'datamapper4rails/rspec_default_values'

class DatamapperRspecScaffoldGenerator < RspecScaffoldGenerator

  def manifest
    overlay_dirs.add_generator("datamapper_rspec_model")
    overlay_dirs.add_generator("datamapper_model")
    overlay_dirs.add_generator("datamapper_scaffold")
    overlay_dirs.add_generator("rspec_scaffold")
    overlay_dirs.add_generator("scaffold")
    super
  end

  def add_options!(opt)
    super
    opt.on("--skip-timestamps",
           "Don't add timestamps for this model") { |v| options[:skip_timestamps] = v }
  end
end
