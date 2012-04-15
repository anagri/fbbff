class BffFinder
  attr_accessor :api, :friend_uid

  def initialize(api, friend_uid)
    @api = api
    @friend_uid = friend_uid
  end

  def before(job)
    @job_id = job.id
  end

  def perform
    data = Hash.new { |h, k| h[k] = 0 }

    paginated_statuses = api.get_connections(friend_uid, 'statuses', :limit => 100)

    rolling_feed = RollingFeed.new(paginated_statuses, 100)
    rolling_feed.each do |feed|
      feed_comments = feed['comments']

      return if feed_comments.nil? # can be nil

      feed_comments_rolling_feed = PaginatedComments.new(api, feed_comments)
      feed_comments_rolling_feed.each do |comment|
        next if comment.nil?
        data[comment['from']['name']]+=1
      end
    end

    feed_result = FeedResult.create!(:job_id => @job_id, :result => data.to_json)
    feed_result
  end
end