require 'datamapper4rails/overlay'
require 'datamapper4rails/rspec_default_values'

class DatamapperScaffoldGenerator < ScaffoldGenerator

  def manifest
    overlay_dirs.add_generator("datamapper_model")
    overlay_dirs.add_generator("scaffold")

    logger.warn
    logger.warn
    logger.warn
    logger.warn
    logger.warn "           WARNING"
    logger.warn
    logger.warn "fixtures with datamapper do not work"
    logger.warn "and so functional tests do not work"
    logger.warn
    logger.warn
    logger.warn
    logger.warn
    
    super
  end

  def add_options!(opt)
    super
    opt.on("--skip-timestamps",
           "Don't add timestamps for this model") { |v| options[:skip_timestamps] = v }
  end
end
