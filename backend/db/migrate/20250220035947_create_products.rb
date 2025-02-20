class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.date :expiration
      t.jsonb :exchange_rates

      t.timestamps
    end
  end
end
