class User
  attr_accessor :uid, :graph

  def initialize(graph, uid)
    @graph = graph
    @uid = uid
  end

  def friends
    graph.get_connections(uid, 'friends', :fields => 'id, name').sort { |f1, f2| f1['name'] <=> f2['name'] }
  end

  def find_bff(friend_uid)
    find_bff_synchronous(friend_uid)
  end

  handle_asynchronously :find_bff

  def likes
    @likes ||= graph.get_connections(uid, 'likes')
  end

  def likes_by_category
    @likes_by_category ||= likes.sort_by { |l| l['name'] }.group_by { |l| l['category'] }.sort
  end

  # for testing purpose only
  def find_bff_synchronous(friend_id)
    data = Hash.new { |h, k| h[k] = 0 }
    friend_feed = graph.get_connections(friend_id, 'feed')
    rolling_feed = RollingFeed.new(friend_feed, 100)
    while rolling_feed.has_next?
      feed_comments = rolling_feed.next['comments']
      next if feed_comments['count'] == 0
      comments = feed_comments['data']
      comments.each do |comment|
        data[comment['from']['name']]+=1
      end
    end
    data
  end
end
