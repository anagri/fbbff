require 'spec_helper'

describe RollingFeed do
  context 'has_next?' do
    it 'should return false if feed read till allowable limit' do
      rolling_feed = RollingFeed.new(['1'], 1)
      rolling_feed.next
      rolling_feed.should_not be_has_next
    end
  end

  context 'next' do
    it 'should return the next element' do
      rolling_feed = RollingFeed.new(['1', '2'], 2)
      rolling_feed.next.should == '1'
      rolling_feed.next.should == '2'
    end

    it 'should fetch the next_page if end of feed' do
      feed = ['1']

      def feed.next_page
        ['2']
      end

      rolling_feed = RollingFeed.new(feed, 2)
      rolling_feed.next.should == '1'
      rolling_feed.next.should == '2'
    end

    it 'return throw exception if read maximum allowed feeds' do
      rolling_feed = RollingFeed.new(['1'], 1)
      rolling_feed.next.should == '1'
      lambda {
        rolling_feed.next
      }.should raise_error('Cannot read more than maximum allowed feed')
    end
  end
end