class CreateXrps < ActiveRecord::Migration[5.1]
  def change
    create_table :xrps do |t|
      t.timestamps

      t.datetime(:date, null: false)
      t.float(:price, null: false)
      t.float(:open, null: false)
      t.float(:high, null: false)
      t.float(:low, null: false)
      t.float(:change)
    end
  end
end
