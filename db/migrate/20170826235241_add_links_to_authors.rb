class AddLinksToAuthors < ActiveRecord::Migration[5.1]
  def change
    add_column :authors, :link, :string
  end
end
