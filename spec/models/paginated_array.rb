class PaginatedArray
  delegate :[], :count, :size, :to => :@arr

  def initialize(*arr)
    @arr = arr.first || []
    @rest = arr[1..-1] || []
  end

  def next_page
    PaginatedArray.new(*@rest)
  end
end
