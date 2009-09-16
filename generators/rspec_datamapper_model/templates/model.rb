class <%= class_name %>
  include DataMapper::Resource
<% if options[:add_constraints] -%>
  include DataMapper::Constraints
<% end -%>

  property :id, Serial

<% for attribute in attributes -%>
  property :<%= attribute.name %>, <%= attribute.type.to_s.camelize %>, :nullable => false <% if attribute.type == :string or attribute.type == :text or attribute.type == :slug -%>, :format => /^[^<'&">]*$/<% if attribute.type == :string or attribute.type == :slug %>, :length => 255<% end -%><% end -%>

<% end -%>
<% unless options[:skip_timestamps] %>
  timestamps :at

<% end -%>

end
