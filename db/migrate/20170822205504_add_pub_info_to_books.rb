class AddPubInfoToBooks < ActiveRecord::Migration[5.1]
  def change
    add_column :books, :isbn, :string
    add_column :books, :publication_date, :date
  end
end
