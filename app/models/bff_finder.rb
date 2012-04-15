class BffFinder
  attr_accessor :graph, :friend_uid

  def initialize(graph, friend_uid)
    @graph = graph
    @friend_uid = friend_uid
  end

  def before(job)
    @job_id = job.id
  end

  def perform
    data = Hash.new { |h, k| h[k] = 0 }

    paginated_statuses = graph.get_connections(friend_uid, 'statuses', :limit => 100)

    rolling_feed = RollingFeed.new(paginated_statuses, 100)
    rolling_feed.each do |feed|
      feed_comments = feed['comments']

      return if feed_comments.nil? # can be nil

      feed_comments_rolling_feed = RollingFeed.new(feed_comments, false,
                                                   :data_extractor => data_extractor,
                                                   :next_page_call => next_page_call)
      feed_comments_rolling_feed.each do |comment|
        next if comment.nil?
        data[comment['from']['name']]+=1
      end
    end

    feed_result = FeedResult.create!(:job_id => @job_id, :result => data.to_json)
    feed_result
  end

  private
  def next_page_call
    Proc.new do |c|
      if (c['paging'] && c['paging']['next'])
        base, args = Koala::Facebook::API::GraphCollection.parse_page_url(c['paging']['next'])
        @graph.get_page([base, args])
      else
        []
      end
    end
  end

  def data_extractor
    Proc.new { |c| c == [] ? [] : c['data'] }
  end
end