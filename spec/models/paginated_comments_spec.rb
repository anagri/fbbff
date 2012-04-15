require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/paginated_array')

describe PaginatedComments do
  it 'should understand the comments when returned via statuses' do
    api = stub('api', :get_page => [])
    c = []
    PaginatedComments.new(api, 'data' => [{"from"=>{"name"=>"Friend 1"}}, {"from"=>{"name"=>"Friend 2"}}]).each do |comment|
      c << comment['from']['name']
    end
    c.should == ['Friend 1', 'Friend 2']
  end

  it 'should understand the comments when returned via fetching next page of comments' do
    api = stub('api')
    next_page_of_comments = PaginatedArray.new([{"from"=>{"name"=>"Friend 3"}}, {"from"=>{"name"=>"Friend 4"}}])
    api.should_receive(:get_page).with(['base', {'args' => 'val'}]).and_return(next_page_of_comments)
    c = []
    PaginatedComments.new(api, 'data' => [{"from"=>{"name"=>"Friend 1"}}], 'paging' => {'next' => 'http://fb.com/base?args=val'}).each do |comment|
      c << comment['from']['name']
    end
    c.should == ['Friend 1', 'Friend 3', 'Friend 4']
  end
end