class CreateBitcoins < ActiveRecord::Migration
  def change
    create_table :bitcoins do |t|
      t.float :price
      t.string :currency

      t.timestamps
    end
  end
end
