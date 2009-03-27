require 'datamapper4rails/adapters/base_adapter'
require 'net/http'
require 'extlib/inflection'
require 'extlib/module'
require 'dm-serializer'

module DataMapper
  module Adapters
    class RestfulAdapter < BaseAdapter

      include ::Slf4r::Logger

      def resource_name_from_model(model)
        ::Extlib::Inflection.underscore(model.name)
      end

      def resource_name_from_query(query)
        resource_name_from_model(query.model)
      end

      def keys_from_query(query)
        keys = query.model.key
        # work around strange missing of properties in model
        # but the query has still the fields :P
        if keys.size == 0
          query.fields.select do |f|
            f.key?
          end
        else
          keys
        end
      end

      def key_value_from_query(query)
        keys = keys_from_query(query)
        logger.debug { "keys=#{keys.inspect}" }
        if keys.size == 1
          key = keys[0]
          # return the third element of the condition array
          # which belongs to the key
          query.conditions.detect do |c|
            c[1] == key
          end[2]
        else
          raise "compound keys are not supported"
        end
      end
      
      def single_entity_query?(query)
        query.conditions.count {|c| c[1].key? and c[0] == :eql} == query.model.key.size
      end

      def attributes_to_xml(name, attributes)
        xml = "<#{name}>"
        attributes.each do |attr, val|
          xml += "<#{attr.name}>#{val}</#{attr.name}>"
        end
        xml += "</#{name}>"
      end

      def http_get(uri)
        send_request do |http|
          request = Net::HTTP::Get.new(uri)
          request.basic_auth(@uri[:login], 
                             @uri[:password]) unless @uri[:login].blank?
          http.request(request)
        end
      end

      def http_post(uri, data = nil)
        send_request do |http|
          request = Net::HTTP::Post.new(uri, {
                                          'content-type' => 'application/xml',
                                          'content-length' => data.length.to_s
                                        })
          request.basic_auth(@uri[:login], 
                             @uri[:password]) unless @uri[:login].blank?
          http.request(request, data)
        end
      end

      def http_put(uri, data = nil)
        send_request do |http|
          request = Net::HTTP::Put.new(uri, {
                                          'content-type' => 'application/xml',
                                          'content-length' => data.length.to_s
                                        })
          request.basic_auth(@uri[:login], 
                             @uri[:password]) unless @uri[:login].blank?
#          request.set_form_data(data)
          http.request(request, data)
        end
      end

      def http_delete(uri)
        send_request do |http|
          request = Net::HTTP::Delete.new(uri)
          request.basic_auth(@uri[:login], 
                             @uri[:password]) unless @uri[:login].blank?
          http.request(request)
        end
      end

      def send_request(&block)
        res = nil
        Net::HTTP.start(@uri[:host], @uri[:port].to_i) do |http|
          res = yield(http)
        end
        logger.debug { "response=" + res.code }
        res
      end

      def parse_resource(xml, model, query = nil)
        elements = {}
        associations = {}
        many_to_many = {}
        xml.elements.collect do |element|
          if element.text.nil? 
            if element.attributes['type'] == 'array'
              many_to_many[element.name.gsub('-','_').to_sym] = element
            else
              associations[element.name.gsub('-','_').to_sym] = element
            end
          else
            elements[element.name.gsub('-','_').to_sym] = element.text
          end
        end
#puts
#puts "elements"
#p elements
#p query
#p model
        resource = model.load(model.properties.collect do |f|
                                  elements[f.name]
                                end, query)
        resource.send("#{keys_from_query(query)[0].name}=".to_sym, elements[keys_from_query(query)[0].name] )
# p resource
#p associations
        associations.each do |name, association| 
#          puts "asso"
#          p model
#          p name
#          p association
#p model.relationships
          is_one_to_one = false
          asso_model = 
            if rel = model.relationships[name]
#puts "rel"
#p rel
              if rel.child_model == model
                rel.parent_model
              else
                rel.child_model
              end
              #                  else
#::Extlib::Inflection.constantize(::Extlib::Inflection.classify(name))
#                    model.find_const(::Extlib::Inflection.classify(name))
            end
  #        p asso_model
          if resource.respond_to? "#{name}=".to_sym
           #  puts
#             puts "association"
#             puts name
#             p model
#             p asso_model
            resource.send("#{name}=".to_sym, 
                          parse_resource(association, asso_model,
                                         ::DataMapper::Query.new(query.repository, asso_model ))) unless asso_model.nil?
          else
            resource.send(("#{name.to_s.pluralize}<" + "<").to_sym, 
                          parse_resource(association, asso_model,
                                         ::DataMapper::Query.new(query.repository, asso_model ))) unless asso_model.nil?
          end
        end

#puts "many 2 many"
#p many_to_many
        many_to_many.each do |name, many|
          if model.relationships[name]
            # TODO
          else
 #           p ::Extlib::Inflection.classify(name.to_s.singularize)
            many_model = Object.const_get(::Extlib::Inflection.classify(name.to_s.singularize))
            resource.send(name).send(("<" + "<").to_sym, 
                       parse_resource(many, many_model,
                                      ::DataMapper::Query.new(query.repository, many_model ))) unless many_model.nil?
          end
        end
        resource.instance_variable_set(:@new_record, false)
#p resource
        resource
      end

      # @see BaseAdapter
      def create_resource(resource)
        name = resource.model.name
        uri = "/#{name.pluralize}.xml"
        logger.debug { "post #{uri}" }
        response = http_post(uri, resource.to_xml )
        resource_new = parse_resource(REXML::Document::new(response.body).root, 
                                  resource.model,
                                  ::DataMapper::Query.new(resource.repository, 
                                                          resource.model ))

        # copy all attributes/associations from the downloaded resource
        # to the given resource
        # TODO better pass the given resource into parse_resource
        resource_new.attributes.each do |key, value|
          resource.send(:properties)[key].set!(resource, value)
        end
        resource_new.send(:relationships).each do |key, value|
          resource.send("#{key}=".to_sym, resource_new.send(key))
        end
        resource
      end

      # @see BaseAdapter
      def read_resource(query)
        key = key_value_from_query(query)
        uri = "/#{resource_name_from_query(query).pluralize}/#{key}.xml"
        logger.debug { "get #{uri}" }
        response = http_get(uri)
        if response.kind_of?(Net::HTTPSuccess)
          logger.debug { response.body.to_s }
          parse_resource(REXML::Document::new(response.body).root, 
                         query.model, 
                         query)
        else
            #TODO may act on different response codes differently
        end
      end

      # @see BaseAdapter
      def read_resources(query)
        if single_entity_query?(query)
          [read_resource(query)]
        else
          uri = "/#{resource_name_from_query(query).pluralize}.xml"
          logger.debug { "get #{uri}" }
          response = http_get(uri)
          if response.kind_of?(Net::HTTPSuccess)
            result = []
            logger.debug { response.body.to_s }
            REXML::Document::new(response.body).root.each do |element|
              result << parse_resource(element, 
                                       query.model, 
                                       query)
            end
            result
          else
            #TODO may act on different response codes differently
          end
        end
      end

      # @overwrite BaseAdapter
      def update(attributes, query)
        if query.limit == 1 or single_entity_query?(query)
          xml = attributes_to_xml(resource_name_from_query(query), attributes)
          key = key_value_from_query(query)
          uri = "/#{resource_name_from_query(query).pluralize}/#{key}.xml"
          logger.debug { "put #{uri}" }
          response = http_put(uri, xml)
          response.kind_of?(Net::HTTPSuccess)
        else
          super
        end
      end

      # @see BaseAdapter
      def update_resource(resource, attributes)
        query = resource.to_query
        xml = attributes_to_xml(resource.name, attributes)
        key = key_value_from_query(query)
        logger.debug {resource.to_xml}
        response = http_put("/#{resource_name_from_query(query).pluralize}/#{key}.xml", xml)
        response.kind_of?(Net::HTTPSuccess)
      end
      
      # @overwrite BaseAdapter
      def delete(query)
        if query.limit == 1 or single_entity_query?(query)
          name = resource_name_from_query(query)
          key = key_value_from_query(query)
          uri = "/#{name.pluralize}/#{key}.xml"
          logger.debug { "delete #{uri}" }
          response = http_delete(uri)
          response.kind_of?(Net::HTTPSuccess) 
        else
          super
        end
      end

      # @see BaseAdapter
      def delete_resource(resource)
        name = resource.name
        key = key_value_from_query(resource.to_query)
        uri = "/#{name.pluralize}/#{key}.xml"
        logger.debug { "delete #{uri}" }
        response = http_delete(uri)
        response.kind_of?(Net::HTTPSuccess) 
      end
    end
  end
end
