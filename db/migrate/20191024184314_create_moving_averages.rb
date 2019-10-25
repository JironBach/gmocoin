class CreateMovingAverages < ActiveRecord::Migration[5.1]
  def change
    create_table :moving_averages do |t|
      t.timestamps

      t.datetime(:date, null: false)
      t.float(:price, null: false)
      t.float(:ma75, null: false)
      t.float(:ma25, null: true)
      t.boolean(:golden_cross, null: true)
      t.datetime(:golden_date, null: true)
      t.boolean(:dead_cross, null: true)
      t.datetime(:dead_date, null: true)
    end
  end
end
