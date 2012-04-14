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
    friend_feed = graph.get_connections(friend_uid, 'feed')

    rolling_feed = RollingFeed.new(friend_feed, 100)
    while rolling_feed.has_next?
      feed_comments = rolling_feed.next['comments']
      next if feed_comments['count'] == 0
      comments = feed_comments['data']
      comments.each do |comment|
        data[comment['from']['name']]+=1
      end
    end
    FeedResult.create!(:job_id => @job_id, :result => data.to_json)
  end
end