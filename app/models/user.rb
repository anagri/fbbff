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
    Delayed::Job.enqueue BffFinder.new(@graph, friend_uid)
  end

  def likes
    @likes ||= graph.get_connections(uid, 'likes')
  end

  def likes_by_category
    @likes_by_category ||= likes.sort_by { |l| l['name'] }.group_by { |l| l['category'] }.sort
  end
end
