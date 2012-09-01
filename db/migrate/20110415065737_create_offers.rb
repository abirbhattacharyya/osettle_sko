class CreateOffers < ActiveRecord::Migration
  def self.up
    create_table :offers do |t|
      t.integer :feed_id
      t.string :response
      t.float :amount

      t.timestamps
    end
  end

  def self.down
    drop_table :offers
  end
end
