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
    if get_data.size <= @current_index
      @arr = get_next_page
      @current_index = 0
    end
    get_data.size != 0 && (!@max || @total_read < @max)
  end

  def next
    raise 'Cannot read more elements' if !has_next?
    next_val = get_next_element
    @current_index+=1
    @total_read+=1

    next_val
  end

  private
  def get_next_page
    @arr.next_page
  end

  def get_data
    @arr
  end

  def get_next_element
    get_data[@current_index]
  end
end