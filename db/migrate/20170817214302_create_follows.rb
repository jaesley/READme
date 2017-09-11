class CreateFollows < ActiveRecord::Migration[5.1]
  def change
    create_table :follows do |t|
      t.integer :user_id
      t.integer :author_id

      t.timestamps
    end
    
    add_index :follows, [:user_id, :author_id], unique: true
  end
end
