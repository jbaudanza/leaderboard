class Initial < ActiveRecord::Migration
  def up
    create_table :identities do |t|
      t.timestamps :null => false
      t.integer :balance, :limit => 8
      t.string :name, :null => false
    end

    create_table :addresses do |t|
      t.timestamps :null => false
      t.belongs_to :identity, :null => false
      t.string :address, :null => false
      t.integer :balance, :limit => 8
    end
  end

  def down
    drop_table :identities
    drop_table :addresses
  end
end
