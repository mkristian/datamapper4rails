$LOAD_PATH << File.dirname(__FILE__)
require 'spec_helper'
require 'datamapper4rails/datamapper_store'

describe ActionController::Session::DatamapperStore do

  def mock_session(stubs={})
    @mock_session ||= mock(Session, stubs)
  end
  
  before :each do
    @store = ActionController::Session::DatamapperStore.new(nil, :session_class => Session)
  end
  
  it 'should create a new session' do
    Session.should_receive(:create).and_return(mock_session)
    mock_session.should_receive(:data).and_return({})
    result = @store.send(:get_session, {}, nil)
    result[0].should_not be_nil
    result[1].should == {}
  end
  
end
