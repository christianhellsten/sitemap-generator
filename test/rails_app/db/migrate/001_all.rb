class All < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :name
    end
  end
 
  def self.down
    drop_table :posts
  end
end
