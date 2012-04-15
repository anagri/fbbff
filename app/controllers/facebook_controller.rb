class FacebookController < ApplicationController

  before_filter :facebook_auth
  before_filter :require_login, :except => :login

  helper_method :logged_in?, :current_user

  def index
    @friends = current_user.friends
  end

  def login
    if logged_in?
      redirect_to :action => :index
    end
  end

  def bff
    job = current_user.find_bff(params['friend_uid'])
    session[current_user.uid]['job'] = job.id
  end

  def bff_job_status
    job_id = session[current_user.uid]['job']
    if !Delayed::Job.exists?(job_id)
      result = FeedResult.where('job_id = ?', job_id)[0].result
      render :json => result
    else
      render :nothing => true, :status => 307
    end
  end

  protected
  def logged_in?
    !!@user
  end

  def current_user
    @user
  end

  def require_login
    unless logged_in?
      redirect_to :action => :login
    end
  end

  def facebook_auth
    @oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_SECRET_KEY)
    cookies = request.cookies
    #pp cookies
    if fb_user_info = @oauth.get_user_info_from_cookie(cookies)
      @graph = Koala::Facebook::API.new(fb_user_info['access_token'])
      @user = User.new(@graph, fb_user_info['user_id'])
      session[@user.uid] ||= {}
    end
  end
end
