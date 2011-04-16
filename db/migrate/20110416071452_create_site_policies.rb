class CreateSitePolicies < ActiveRecord::Migration
  def self.up
    create_table :site_policies do |t|
      t.integer :topic_id
      t.integer :user_id
      t.integer :restaurant_id
      t.string :name
      t.text :policy

      t.timestamps
    end
  end

  def self.down
    drop_table :site_policies
  end
end
