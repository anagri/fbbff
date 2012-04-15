require 'spec_helper'

describe User do
  before do
    @graph = mock('graph api')
    @uid = 42
    @user = User.new(@graph, @uid)
  end

  describe 'retrieving bff' do
    it 'should start background job for processing bff' do
      # verifying the invocation is going to delayed job
      # delayed job deletes completed tasks, so cannot rely on records in table
      BffFinder.should_receive(:new).with(@graph, '12345').and_return(stub('bff_finder', 'perform' => ''))
      job = @user.find_bff('12345')
      job.class.should == Delayed::Backend::ActiveRecord::Job
    end
  end

  describe 'retrieving friends' do
    before do
      @graph.should_receive(:get_connections).with(@uid, 'friends', anything()).and_return([{'name' => 'friend 2'}, {'name' => 'friend 1'}])
    end

    it 'should return friends sorted by name when returned by api' do
      @user.friends.should == [{'name' => 'friend 1'}, {'name' => 'friend 2'}]
    end
  end
end
