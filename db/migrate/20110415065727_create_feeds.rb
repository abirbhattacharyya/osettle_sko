class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.integer :user_id
      t.string :account_number
      t.string :client_number
      t.string :client_account_number
      t.float :balance
      t.datetime :last_payment_date
      t.integer :last_pay_amount
      t.float :max_pct
      t.float :floor_limit
      t.integer :payment_term
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.text :address1
      t.text :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone1
      t.string :phone2
      t.string :phone3
      t.string :phone4
      t.string :client_name1
      t.string :client_name2
      t.timestamps
    end
  end

  def self.down
    drop_table :feeds
  end
end
