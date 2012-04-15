class BffFinder
  attr_accessor :api, :friend_uid

  def initialize(api, friend_uid)
    @api = api
    @friend_uid = friend_uid
  end

  def before(job)
    @job_id = job.id
    p "#{Time.now} - started processing job #{@job_id}"
  end

  def perform
    data = Hash.new { |h, k| h[k] = 0 }

    paginated_statuses = api.get_connections(friend_uid, 'statuses', :limit => 100)

    rolling_feed = RollingFeed.new(paginated_statuses, 100)
    rolling_feed.each do |feed|
      feed_comments = feed['comments']
      if feed_comments.present? # can be nil
        feed_comments_rolling_feed = PaginatedComments.new(api, feed_comments)
        feed_comments_rolling_feed.each do |comment|
          if comment.present?
            data[comment['from']['name']]+=1
          end
        end
      end
    end

    final_result = {"result" => data.inject([]) { |c, e| c << {'name' => e[0], 'count' => e[1]}; c }}.to_json

    feed_result = FeedResult.create!(:job_id => @job_id, :result => final_result)
    p "#{Time.now} - finished processing job #{@job_id}"
    feed_result
  end
end