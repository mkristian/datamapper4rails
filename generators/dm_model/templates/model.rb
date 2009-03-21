class <%= class_name %>
  include DataMapper::Resource
  property :id, Serial

<% for attribute in attributes -%>
  property :<%= attribute.name %>, <%= attribute.type.to_s.capitalize %>, :nullable => false 

<% end -%>
<% unless options[:skip_timestamps] %>
  property :created_at, DateTime, :nullable => false
  property :updated_at, DateTime, :nullable => false

<% end -%>
end
