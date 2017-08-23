class CreateBooks < ActiveRecord::Migration[5.1]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :goodreads_i, null: false, index: { unique: true }
      t.integer :author_id, null: false

      t.timestamps
    end
  end
end
