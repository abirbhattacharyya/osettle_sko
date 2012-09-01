class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :offer_id
      t.float :amount
      t.string :payment_type
      t.date :payment_date
      t.string :name
      t.string :cc_no
      t.integer :cc_expiry_m
      t.integer :cc_expiry_y
      t.string :email

      t.timestamps
    end
    add_column :payments, :routing_no, :string
    add_column :payments, :bank_ac_no, :string
  end

  def self.down
    drop_table :payments
  end
end
