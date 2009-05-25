$LOAD_PATH << File.dirname(__FILE__)
require 'spec_helper'
require 'datamapper4rails/adapters/restful_adapter'
require 'slf4r/ruby_logger'

class Item
  include DataMapper::Resource

  property :id, Serial
  property :name, String

  belongs_to :group
end
class User
  include DataMapper::Resource

  property :id, Serial

  belongs_to :container
  has n, :groups, :through => Resource
end
class Group
  include DataMapper::Resource

  property :id, Serial

  has n, :users, :through => Resource
  has n, :items
end

class Container
  include DataMapper::Resource

  property :id, Serial

  has 1, :user

  def items
    @items ||= []
  end
end

def mock_attribute(name)
  attr = Object.new
  def attr.name
    @name
  end
  def attr.name=(name)
    @name = name
  end
  attr.name= name
  attr
end

def mock_item(stubs={})
  @mock_item ||= mock(Item, stubs)
end

def mock_query(stubs={})
  @mock_query ||= mock(DataMapper::Query, stubs)
end

describe DataMapper::Adapters::RestfulAdapter do

  before :each do
    @adapter = DataMapper::Adapters::RestfulAdapter.new(:name, "uri://")

    def @adapter.key_value_from_query(query)
      432
    end
    def @adapter.resource_name_from_query(query)
      "item"
    end
    def @adapter.http_put(uri, data)
      @uri = uri
      @data = data
    end
    def @adapter.http_delete(uri)
      @uri = uri
    end
    def @adapter.data
      @data
    end
    def @adapter.uri
      @uri
    end
    def @adapter.body=(b)
      @body = b
    end
    def @adapter.send_request
      res = Object.new
      def res.body=(b)
        @body = b
      end
      def res.body
        @body
      end
      def res.kind_of?(clazz)
        true
      end
      res.body= @body
      res
    end
    
  end

  it 'should create an Item' do
    @adapter.body = "<item><id>123</id><name>zappa</name></item>"

    item = Item.new
    @adapter.create_resource(item).should == item
    item.id.should == 123
    item.name.should == 'zappa'
  end

  it 'should update an Item' do
    mock_item.should_receive(:to_query)
    mock_item.should_receive(:name).and_return("item")
    mock_item.should_receive(:to_xml)
    
    @adapter.update_resource(mock_item, mock_attribute(:name) => "frank zappa")

    @adapter.data.should == "<item><name>frank zappa</name></item>"
  end

  it 'should update Items' do    
    mock_query.should_receive(:limit).and_return(1)
    @adapter.update({mock_attribute(:name) => "frank zappa"}, mock_query)

    @adapter.data.should == "<item><name>frank zappa</name></item>"
  end

  it 'should delete an Item' do
    mock_item.should_receive(:name).and_return("item")
    mock_item.should_receive(:to_query)
    @adapter.delete_resource(mock_item)
    @adapter.uri.should == "/items/432.xml"
  end

  it 'should delete Items' do    
    mock_query.should_receive(:limit).and_return(1)
    @adapter.delete(mock_query)

    @adapter.uri.should == "/items/432.xml"
  end

  it 'should read an Item' do
    @adapter.body = "<item><id>123</id><name>zappa</name></item>"

    query = DataMapper::Query.new(Item.new.repository, Item)
    item = @adapter.read_resource(query)
    item.id.should == 123
    item.name.should == 'zappa'
  end

  it 'should read Items' do
    @adapter.body = "<items type='array'><item><id>123</id><name>zappa</name></item></items>"

    query = DataMapper::Query.new(Item.new.repository, Item)
    items = @adapter.read_resources(query)
    items.size.should == 1
    items[0].id.should == 123
    items[0].name.should == 'zappa'
  end
#end


#describe 'associations of ' + DataMapper::Adapters::RestfulAdapter.to_s do
  it 'should read nested resource (belongs_to)' do
    @adapter.body = "<item><id>123</id><name>zappa</name>" +
      "<group><id>342</id>" + #<items tpye='array'><item><id>1234</id><name>frank zappa</name></item></items>" + 
      "</group>" +
      "</item>"

    query = DataMapper::Query.new(Item.new.repository, Item)
    item = @adapter.read_resource(query)
    item.id.should == 123
    item.name.should == 'zappa'
    item.group.id.should == 342
  end

  it 'should read nested resource manual "has n"' do
    @adapter.body = "<container><id>342</id><items type='array'>" +
      "<item><id>543</id><name>hmm</name></item>" +
      "</items></container>"

    query = DataMapper::Query.new(Container.new.repository, Container)
    c = @adapter.read_resource(query)
    c.id.should == 342
    c.items.size.should == 1
    c.items[0].id.should == 543
    c.items[0].name.should == 'hmm'
  end

#   it 'should read nested resource (has 1)' do
#     @adapter.body = "<container><id>342</id>" +
#       "<user><id>543</id></user>" +
#       "</container>"

#     query = DataMapper::Query.new(Container.new.repository, Container)
#     c = @adapter.read_resource(query)
#     c.id.should == 342
#   end
end
