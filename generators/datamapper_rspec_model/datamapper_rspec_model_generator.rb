require 'rails_generator/generators/components/model/model_generator'
require 'active_record'
require 'datamapper4rails/overlay'

class DatamapperRspecModelGenerator < RspecModelGenerator

  def manifest
    overlay_dirs.add_generator("datamapper_model")
    overlay_dirs.add_generator("rspec_model")
    super
  end

  def add_options!(opt)
    super
    opt.on("--skip-timestamps",
           "Don't add timestamps for this model") { |v| options[:skip_timestamps] = v }
  end
end
