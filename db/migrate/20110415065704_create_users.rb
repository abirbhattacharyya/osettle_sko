class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
			t.string :email, :limit => 100
			t.string :password
      t.string :remember_token
      t.string :remember_token_expires_at
      t.boolean :is_verified, :default => false

      t.timestamps
    end
    add_column :users, :account_number, :string
  end

  def self.down
    drop_table :users
  end
end
