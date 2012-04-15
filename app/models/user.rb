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
end
