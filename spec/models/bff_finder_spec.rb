require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/rollover_feed')

describe BffFinder do
  it 'fetch comments for given friend and do processing' do
    # given
    rollover_feed = prepare_test_feed # test feed with two user's comments

    @graph = mock('graph')
    @graph.should_receive(:get_connections).with('12345', 'feed').and_return(nil)
    RollingFeed.should_receive(:new).with(anything, anything).and_return(rollover_feed) # duck type interface

    # when
    @bff_finder = BffFinder.new(@graph, '12345')
    @bff_finder.before(stub('job', 'id' => 1))
    feed_result = @bff_finder.perform

    # then
    feed_result['job_id'].should == 1
    feed_result['result'].should == "{\"Test User 2\":67,\"Test User 3\":33}"
  end

  def prepare_test_feed
    feed_1 = {
        "comments" => {
            "data" => [
                {
                    "id" => "test_user_comment_id",
                    "from" => {
                        "name" => "Test User 2",
                        "id" => "test_user_2_id"
                    },
                    "message" => "test message",
                    "created_time" => "test time"
                }
            ],
            "count" => 1
        }
    }
    feed_2 = {
        "comments" => {
            "data" => [
                {
                    "id" => "test_user_comment_id",
                    "from" => {
                        "name" => "Test User 3",
                        "id" => "test_user_3_id"
                    },
                    "message" => "test message",
                    "created_time" => "test time"
                }
            ],
            "count" => 1
        }
    }
    rollover_feed = RolloverFeed.new([feed_1, feed_2, feed_1])
    rollover_feed
  end
end