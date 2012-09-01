class AddLogoToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :logo, :string
  end

  def self.down
    remove_column :profiles, :logo
  end
end
