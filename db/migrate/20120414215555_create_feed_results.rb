class CreateFeedResults < ActiveRecord::Migration
  def self.up
    create_table :feed_results do |t|
      t.integer :job_id
      t.text :result
    end
  end

  def self.down
    drop_table :feed_results
  end
end
