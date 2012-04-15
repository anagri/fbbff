require 'spec_helper'


describe RollingFeed do
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

  context 'each' do
    it 'should iterate till the given item count' do
      c = []
      RollingFeed.new(PaginatedArray.new(['1', '2', '3']), 2).each { |i| c << i }
      c.should == ['1', '2']
    end

    it 'should iterate over all the items' do
      c = []
      RollingFeed.new(PaginatedArray.new(['1'], ['2'], ['3']), 4).each { |i| c << i }
      c.should == ['1', '2', '3']
    end

    it 'should read till end if passed max count as false' do
      c = []
      RollingFeed.new(PaginatedArray.new(['1'], ['2'], ['3']), false).each { |i| c << i }
      c.should == ['1', '2', '3']
    end
  end

  context 'has_next?' do
    it 'should return false if feed read till allowable limit' do
      rolling_feed = RollingFeed.new(PaginatedArray.new(['1', '2']), 1)
      rolling_feed.next
      rolling_feed.has_next?.should be_false
    end

    it 'should return false if fetching more feed items return no elements' do
      rolling_feed = RollingFeed.new(PaginatedArray.new(['1'], []), 2)
      rolling_feed.next
      rolling_feed.has_next?.should be_false
    end
  end

  context 'next' do
    it 'should return the next element' do
      rolling_feed = RollingFeed.new(['1', '2'], 2)
      rolling_feed.next.should == '1'
      rolling_feed.next.should == '2'
    end

    it 'should fetch the next_page if end of feed' do
      feed = PaginatedArray.new(['1'], ['2'])
      rolling_feed = RollingFeed.new(feed, 2)
      rolling_feed.next.should == '1'
      rolling_feed.next.should == '2'
      rolling_feed.has_next?.should be_false
    end

    it 'should throw exception if read maximum allowed feeds' do
      rolling_feed = RollingFeed.new(PaginatedArray.new(['1', '2']), 1)
      rolling_feed.next
      lambda {
        rolling_feed.next
      }.should raise_error('Cannot read more elements')
    end
  end
end