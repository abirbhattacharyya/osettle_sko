class AddEmailInFeeds < ActiveRecord::Migration
  def self.up

    add_column :feeds,:email,:string
  end

  def self.down
    remove_column :feeds,:email
  end
end
