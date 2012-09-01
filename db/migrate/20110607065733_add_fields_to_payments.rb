class AddFieldsToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :security_code, :integer
    add_column :payments, :billing_address, :text
    add_column :payments, :city, :string
    add_column :payments, :state, :string
    add_column :payments, :zip, :integer
  end

  def self.down
    remove_column :payments, :zip
    remove_column :payments, :state
    remove_column :payments, :city
    remove_column :payments, :billing_address
    remove_column :payments, :security_code
  end
end
