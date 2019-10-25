class ChangeColumnMovingAverage < ActiveRecord::Migration[5.1]
  def up
    change_column(:moving_averages, :created_at, :datetime, :null => true)
    change_column(:moving_averages, :updated_at, :datetime, :null => true)
  end

  def down
    change_column(:moving_averages, :created_at, :datetime, :null => false)
    change_column(:moving_averages, :updated_at, :datetime, :null => false)
  end

end
