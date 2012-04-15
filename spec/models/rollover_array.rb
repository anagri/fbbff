# A utility test class that keeps on repeating the passed array,
# Only used by test.

class RolloverArray
  def initialize(arr, max = 100)
    @arr = arr
    @max = max
  end

  def size
    @max
  end

  def next_page
    self
  end

  def [](idx)
    idx < @max ? @arr[idx % @arr.count] : nil
  end
end