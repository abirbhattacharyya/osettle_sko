class AddPaymentFieldsInPayments < ActiveRecord::Migration
  def self.up

    add_column :payments,:cc_type,:string
    add_column :payments,:bank_name,:string

  end

  def self.down
    remove_column :payments,:cc_type
    remove_column :payments,:bank_name
  end
end
