class RollingFeed
  def initialize(feed, max = 100)
    @arr = feed
    @max = max
    @current_index = 0
    @total_read = 0
  end

  def each
    while has_next?
      yield self.next
    end
  end

  def has_next?
    # eager fetch the next page
    if @arr.size <= @current_index
      @arr = @arr.next_page
      @current_index = 0
    end
    @arr.size != 0 && (!@max || @total_read < @max)
  end

  def next
    raise 'Cannot read more elements' if !has_next?
    next_val = @arr[@current_index]
    @current_index+=1
    @total_read+=1

    next_val
  end
end