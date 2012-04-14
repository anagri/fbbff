require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/rollover_feed')

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
      job = @user.find_bff('12345')
      job.class.should == Delayed::Backend::ActiveRecord::Job
    end

    it 'fetch comments for given friend and do processing' do
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

      @graph.should_receive(:get_connections).with('12345', 'feed').and_return(nil)
      RollingFeed.should_receive(:new).with(anything, anything).and_return(rollover_feed) # duck type interface
      user_comments_count = @user.find_bff_synchronous('12345')
      user_comments_count.should == {'Test User 2' => 67, 'Test User 3' => 33}
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

  describe 'retrieving likes' do
    before do
      @likes = [
        {
          "name" => "The Office",
          "category" => "Tv show",
          "id" => "6092929747",
          "created_time" => "2010-05-02T14:07:10+0000"
        },
        {
          "name" => "Flight of the Conchords",
          "category" => "Tv show",
          "id" => "7585969235",
          "created_time" => "2010-08-22T06:33:56+0000"
        },
        {
          "name" => "Wildfire Interactive, Inc.",
          "category" => "Product/service",
          "id" => "36245452776",
          "created_time" => "2010-06-03T18:35:54+0000"
        },
        {
          "name" => "Facebook Platform",
          "category" => "Product/service",
          "id" => "19292868552",
          "created_time" => "2010-05-02T14:07:10+0000"
        },
        {
          "name" => "Twitter",
          "category" => "Product/service",
          "id" => "20865246992",
          "created_time" => "2010-05-02T14:07:10+0000"
        }
      ]
      @graph.should_receive(:get_connections).with(@uid, 'likes').once.and_return(@likes)
    end

    describe '#likes' do
      it 'should retrieve the likes via the graph api' do
        @user.likes.should == @likes
      end

      it 'should memoize the result after the first call' do
        likes1 = @user.likes
        likes2 = @user.likes
        likes2.should equal(likes1)
      end
    end

    describe '#likes_by_category' do
      it 'should group by category and sort categories and names' do
        @user.likes_by_category.should == [
          ["Product/service", [
            {
              "name" => "Facebook Platform",
              "category" => "Product/service",
              "id" => "19292868552",
              "created_time" => "2010-05-02T14:07:10+0000"
            },
            {
              "name" => "Twitter",
              "category" => "Product/service",
              "id" => "20865246992",
              "created_time" => "2010-05-02T14:07:10+0000"
            },
            {
              "name" => "Wildfire Interactive, Inc.",
              "category" => "Product/service",
              "id" => "36245452776",
              "created_time" => "2010-06-03T18:35:54+0000"
            }
          ]],
          ["Tv show", [
            {
              "name" => "Flight of the Conchords",
              "category" => "Tv show",
              "id" => "7585969235",
              "created_time" => "2010-08-22T06:33:56+0000"
            },
            {
              "name" => "The Office",
              "category" => "Tv show",
              "id" => "6092929747",
              "created_time" => "2010-05-02T14:07:10+0000"
            }
          ]]
        ]
      end
    end
  end
end
