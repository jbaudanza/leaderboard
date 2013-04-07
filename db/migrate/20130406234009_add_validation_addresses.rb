class AddValidationAddresses < ActiveRecord::Migration
  def up
    add_column :identities, :validation_address, :string
    add_index :identities, :validation_address
    add_index :identities, :balance

    create_table :validation_addresses do |t|
      t.string :address, :null => false
    end
  end

  def down
    remove_column :identities, :validation_address
    drop_table :validation_addresses
  end
end
