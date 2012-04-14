class RollingFeed
  def initialize(feed, max = 100)
    @feed = feed
    @max = max
    @current_index = 0
    @total_read = 0
  end

  def has_next?
    @total_read < @max
  end

  def next
    raise 'Cannot read more than maximum allowed feed' if !has_next?

    # fetch the next page
    if @feed.count <= @current_index
      @feed = @feed.next_page
      @current_index = 0
    end

    next_val = @feed[@current_index]
    @current_index+=1
    @total_read+=1

    next_val
  end
end