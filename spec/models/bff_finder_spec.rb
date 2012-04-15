require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/rollover_array')

describe BffFinder do
  context 'non paginated comments' do
    it 'fetch comments for given friend and do processing' do
      # given
      rollover_statuses = prepare_test_feed # test feed with two user's comments

      @api = mock('api')
      @api.should_receive(:get_connections).with('12345', 'statuses', :limit => 100).and_return(rollover_statuses)

      # when
      @bff_finder = BffFinder.new(@api, '12345')
      @bff_finder.before(stub('job', 'id' => 1))
      feed_result = @bff_finder.perform

      # then
      feed_result['job_id'].should == 1
      feed_result['result'].should == "{\"result\":[{\"name\":\"Friend 1\",\"count\":100},{\"name\":\"Friend 2\",\"count\":50},{\"name\":\"Friend 3\",\"count\":50}]}"
    end

    def prepare_test_feed
      status_1 = {"comments"=> {"data"=> [{"from"=>{"name"=>"Friend 1"}}, {"from"=>{"name"=>"Friend 3", }}]}}
      status_2 = {"comments"=> {"data"=> [{"from"=>{"name"=>"Friend 2"}}, {"from"=>{"name"=>"Friend 1", }}]}}

      rollover_feed = RolloverArray.new([status_1, status_2], 100)
      rollover_feed
    end
  end
end