# A utility test class that keeps on repeating the passed array,
# Implementing duck type interface for RollingFeed.
# Only used by test.

class RolloverFeed
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
    # just reset the current index, no need to call the next_page
    @current_index = 0 if @feed.count <= @current_index

    next_val = @feed[@current_index]
    @current_index+=1
    @total_read+=1

    next_val
  end
end