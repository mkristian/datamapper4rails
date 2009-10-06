module DataMapper
  module Resource
  
    def has_attribute?(name)
      properties[name] != nil
    end
  end
end
