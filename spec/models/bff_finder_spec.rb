require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/rollover_array')

describe BffFinder do
  it 'fetch comments for given friend and do processing' do
    # given
    rollover_statuses = prepare_test_feed # test feed with two user's comments

    @graph = mock('graph')
    @graph.should_receive(:get_connections).with('12345', 'statuses', :limit => 100).and_return(rollover_statuses)

    # when
    @bff_finder = BffFinder.new(@graph, '12345')
    @bff_finder.before(stub('job', 'id' => 1))
    feed_result = @bff_finder.perform

    # then
    feed_result['job_id'].should == 1
    feed_result['result'].should == "{\"Friend 1\":100,\"Friend 2\":50,\"Friend 3\":50}"
  end

  def prepare_test_feed
    status_1 = {
        "comments"=> {
            "data"=>
                [{"from"=>{"name"=>"Friend 1"}, "message"=>"no"}, {"from"=>{"name"=>"Friend 3", }, "message"=>"yes"}]
        },
        "from"=>{
            "name"=>"My Friend",
        },
        "message"=>"foobar",
    }

    status_2 = {
        "comments"=> {
            "data"=> [{"from"=>{"name"=>"Friend 2"}, "message"=>"no"}, {"from"=>{"name"=>"Friend 1", }, "message"=>"yes"}]
        },
        "from"=>{
            "name"=>"My Friend",
        },
        "message"=>"barfoo",
    }

    rollover_feed = RolloverArray.new([status_1, status_2], 100)
    rollover_feed
  end
end