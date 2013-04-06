class AddValidationAddresses < ActiveRecord::Migration
  def up
    create_table :validation_addresses do |t|
      t.string :address, :null => false
    end
  end

  def down
    drop_table :validation_addresses
  end
end
