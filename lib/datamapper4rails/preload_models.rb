# load all models before each request so relations in datamapper find their classes
MODELS = []
Dir[RAILS_ROOT + "/app/models/**/*.rb"].each do |model|
  model.sub!(/.*models\//, '').sub!(/.rb/, '')
  m = ::Extlib::Inflection.classify(model.to_s)
  MODELS << m
  Object.const_get(m)
end

module ModelLoader
  module Base
    def self.included(base)
      base.prepend_before_filter(ModelLoaderFilter)
    end
  end
  
  class ModelLoaderFilter
    def self.filter(controller)
      MODELS.each do |model|
        Object.const_get(model)
      end
    end
  end
end

::ActionController::Base.send(:include, ModelLoader::Base)
