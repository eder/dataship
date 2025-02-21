class AddIndexesToProducts < ActiveRecord::Migration[8.0]
  def change
    add_index :products, :name
    add_index :products, :price
    add_index :products, :expiration
  end
end
