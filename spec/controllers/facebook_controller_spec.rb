require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FacebookController do
  describe 'friends with GET' do
    before do
      @oauth_stub = stub('oauth', :get_user_info_from_cookie => stub('fb_user_info', :[] => ''))
      @user_mock = mock('user')
      Koala::Facebook::OAuth.should_receive(:new).and_return(@oauth_stub)
      User.should_receive(:new).and_return(@user_mock)
    end

    it 'should search for friends with search term' do
      @user_mock.should_receive(:friends).with('search this').and_return([{'name' => 'friend 1'}, {'name' => 'friend 2'}])
      get :friends, :search => 'search this'
      response.body.should == '[{"name":"friend 1"},{"name":"friend 2"}]'
    end
  end

  describe 'index with GET' do
    before do
      @user = User.new(mock('graph'), 42)
      @oauth = mock('oauth')
      @graph = mock('graph')
      Koala::Facebook::OAuth.should_receive(:new).and_return(@oauth)
    end

    context 'when logged into facebook' do
      before do
        user_info = {'access_token' => '1234567890', 'uid' => 42}
        @oauth.should_receive(:get_user_info_from_cookie).and_return(user_info)
        Koala::Facebook::GraphAPI.should_receive(:new).with('1234567890').and_return(@graph)
        User.should_receive(:new).and_return(@user)
        @likes = mock('likes')
        @user.should_receive(:likes_by_category).and_return(@likes)

        get :index
      end

      it do
        response.should be_success
      end

      it 'should assign likes' do
        assigns[:likes_by_category].should == @likes
      end
    end

    context 'when not logged into facebook' do
      before do
        @oauth.should_receive(:get_user_info_from_cookie).and_return(nil)

        get :index
      end

      it 'should redirect to the login page' do
        response.should redirect_to(:action => :login)
      end
    end
  end

  describe 'login with GET' do
    it 'should render login page' do
      get :login
      response.should be_success
    end

    context 'when logged in to facebook' do
      before do
        @oauth = stub('oauth', :get_user_info_from_cookie => '')
        Koala::Facebook::OAuth.should_receive(:new).and_return(@oauth)
      end

      it 'should redirect to index page' do
        get :login
        response.should redirect_to(:action => :index)
      end
    end
  end
end
