$LOAD_PATH << File.dirname(__FILE__)
require 'spec_helper'
require 'datamapper4rails/datamapper_store'

describe DatamapperStore do

  before :each do
    load 'lib/datamapper4rails/datamapper_store.rb'
    ActionController::Session::DatamapperStore.send(:class_variable_set, :@@session_class, nil)
  end

  it 'should initialize with no cache and default session class' do
    store = ActionController::Session::DatamapperStore.new(nil)
    store.class.send(:class_variable_get, :@@cache).should be_nil
    store.class.send(:class_variable_get, :@@session_class).should == DatamapperStore::Session

    store = ActionController::Session::DatamapperStore.new(nil, :session_class => :some_class)
    store.class.send(:class_variable_get, :@@cache).should be_nil
    store.class.send(:class_variable_get, :@@session_class).should == DatamapperStore::Session
  end

  it 'should initialize with cache and default session class' do
    store = ActionController::Session::DatamapperStore.new(nil, :cache => true)
    store.class.send(:class_variable_get, :@@cache).instance_of?(Hash).should be_true

    store = ActionController::Session::DatamapperStore.new(nil)
    store.class.send(:class_variable_get, :@@cache).instance_of?(Hash).should be_true
  end

  it 'should initialize with custom session class' do
    store = ActionController::Session::DatamapperStore.new(nil, :session_class => Session)
    store.class.send(:class_variable_get, :@@session_class).should == Session

    store = ActionController::Session::DatamapperStore.new(nil, :session_class => :some_class)
    store.class.send(:class_variable_get, :@@session_class).should == Session
  end
end

describe 'DatamapperStore without cache' do

  def mock_session(stubs={})
    @mock_session ||= mock(Session, stubs)
  end

  before :each do
    load 'lib/datamapper4rails/datamapper_store.rb'
    ActionController::Session::DatamapperStore.send(:class_variable_set, :@@cache, nil)
    ActionController::Session::DatamapperStore.send(:class_variable_set, :@@session_class, nil)
    @store = ActionController::Session::DatamapperStore.new(nil, :session_class => Session)
  end

  it 'should get the session data' do
    Session.stub!(:get)
    @store.send(:get_session, nil, "sid").should == ["sid",{}]
    Session.stub!(:get).and_return(mock_session)
    mock_session.should_receive(:data).and_return({:id => "id"})
    @store.send(:get_session, nil, "sid").should == ["sid",{:id => "id"}]
  end

  it 'should set the session data on new session' do
    Session.should_receive(:get)
    Session.should_receive(:new).with(:session_id => "sid").and_return(mock_session)
    mock_session.should_receive(:data=).with({})
    mock_session.should_receive(:dirty?).and_return(true)
    mock_session.should_receive(:updated_at=)
    mock_session.should_receive(:save).and_return(true)
    @store.send(:set_session, nil, "sid", {}).should == true
  end

  it 'should set the session data' do
    Session.should_receive(:get).and_return(mock_session)
    mock_session.should_receive(:data=).with({})
    mock_session.should_receive(:dirty?).and_return(true)
    mock_session.should_receive(:updated_at=)
    mock_session.should_receive(:save).and_return(true)
    @store.send(:set_session, nil, "sid", {}).should == true
  end
end

describe 'DatamapperStore with cache' do

  def mock_session(stubs={})
    @mock_session ||= mock(Session, stubs)
  end

  before :each do
    load 'lib/datamapper4rails/datamapper_store.rb'
    ActionController::Session::DatamapperStore.send(:class_variable_set, :@@cache, nil)
    ActionController::Session::DatamapperStore.send(:class_variable_set, :@@session_class, nil)
    @store = ActionController::Session::DatamapperStore.new(nil, :cache => true, :session_class => Session)
  end

  it 'should get the session data from storage' do
    Session.stub!(:get)
    @store.send(:get_session, nil, "sid").should == ["sid",{}]
    Session.stub!(:get).and_return(mock_session)
    mock_session.should_receive(:data).and_return({:id => "id"})
    @store.send(:get_session, nil, "sid").should == ["sid",{:id => "id"}]
  end

  it 'should get the session data from cache' do
    ActionController::Session::DatamapperStore.send(:class_variable_get, :@@cache)["sid"] = mock_session
    mock_session.should_receive(:data).and_return({:id => "id"})
    @store.send(:get_session, nil, "sid").should == ["sid",{:id => "id"}]
  end

  it 'should set the session data on new session' do
    Session.should_receive(:get)
    Session.should_receive(:new).with(:session_id => "sid").and_return(mock_session)
    mock_session.should_receive(:data=).with({})
    mock_session.should_receive(:dirty?).and_return(true)
    mock_session.should_receive(:updated_at=)
    mock_session.should_receive(:save).and_return(true)
    @store.send(:set_session, nil, "sid", {}).should == true
    ActionController::Session::DatamapperStore.send(:class_variable_get, :@@cache)["sid"].should == mock_session
    
  end

  it 'should set the session data' do
    Session.should_receive(:get).and_return(mock_session)
    mock_session.should_receive(:data=).with({})
    mock_session.should_receive(:dirty?).and_return(false)
    mock_session.should_receive(:save).and_return(true)
    @store.send(:set_session, nil, "sid", {}).should == true
    ActionController::Session::DatamapperStore.send(:class_variable_get, :@@cache)["sid"].should == mock_session
  end
end
