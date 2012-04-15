require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FacebookController do
  context 'logged in user' do
    before do
      fb_user_info = {'user_id' => 'test_user_id', 'access_token' => 'test_access_token'}
      Koala::Facebook::OAuth.
          should_receive(:new).
          with(anything, anything).
          and_return(stub('oauth', :get_user_info_from_cookie => fb_user_info))
      user_stub = stub('user', 'uid' => 'test_user_id', 'find_bff' => stub('job', 'id' => '1'))
      User.should_receive(:new).and_return(user_stub)
    end

    describe 'bff with POST' do
      it 'render success' do
        post :bff, :bff => {:selected_friend => '12345'}
        response.should be_success
        session['test_user_id']['job'].should == '1'
      end
    end

    describe 'bff_status with GET' do
      before do
        (session['test_user_id'] = {})['job'] = 1
      end

      it 'return 307 temporary redirect if the job is pending' do
        Delayed::Job.should_receive(:find).with(1).and_return(stub('job', 'failed_at' => nil))
        get :bff_status
        response.status.should == 307
      end

      it 'return result if job completed' do
        Delayed::Job.should_receive(:find).with(1).and_return(nil)
        FeedResult.should_receive(:find).with('job_id' => 1).and_return('result' => '{"user1"=>10, "user2"=>20}')
        get :bff_status
        response.status.should == 200
        response.body.should == '{"user1"=>10, "user2"=>20}'
      end
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
        Koala::Facebook::API.should_receive(:new).with('1234567890').and_return(@graph)

        User.should_receive(:new).and_return(@user)
        @likes = mock('likes')
        @friends = []
        @user.should_receive(:likes_by_category).and_return(@likes)
        @user.should_receive(:friends).and_return(@friends)
      end

      it 'should render the page' do
        get :index
        response.should be_success
      end

      it 'should assign likes' do
        get :index
        assigns[:likes_by_category].should == @likes
      end

      it 'should assign friends' do
        get :index
        assigns[:friends].should == @friends
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

    context 'when already logged in to facebook' do
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
