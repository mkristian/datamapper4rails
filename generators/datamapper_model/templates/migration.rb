migration <%= Time.now.utc.strftime("%Y%m%d%H%M%S") %>, :<%= migration_name.underscore %> do
  up do
    create_table :<%= table_name %> do
      column :id, Integer, :serial => true
<% Array(attributes).each do |attribute| -%>
      column :<%= attribute.name if attribute %>, <%= attribute.type == :boolean ? "::DataMapper::Types::Boolean" : attribute.type.to_s.capitalize %>, :nullable => false<% if attribute.type == :string %>, :length => 255<% end %>
<% end -%>
<% unless options[:skip_timestamps] -%>
      column :created_at, DateTime, :nullable => false
      column :updated_at, DateTime, :nullable => false
<% end -%>
    end
  end

  down do
    drop_table :<%= table_name %>
  end
end
