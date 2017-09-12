class AddWorksCountToAuthors < ActiveRecord::Migration[5.1]
  def change
    add_column :authors, :works_count, :integer
  end
end
