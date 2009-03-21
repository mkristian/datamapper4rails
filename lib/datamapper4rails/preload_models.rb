# load all models so relations in datamapper find their classes
Dir[RAILS_ROOT + "/app/models/**/*.rb"].each do |model|
  load model
end
