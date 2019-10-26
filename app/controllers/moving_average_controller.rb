CONST_DATE = 0
CONST_PRICE = 1

class MovingAverageController < ApplicationController
  def calc(day)
    @ma_data = Xrp.all.order(:date)
    @ma_date = []
    @ma_calc = []
    sum = 0
    @ma_data.count.times do |j|
      day.times do |i|
        next if j <= day
        sum += @ma_data[j-day+i].price
        @ma_date << @ma_data[j-day+i].date
      end
      @ma_calc << sum / day
      sum = 0
    end
    return @ma_date, @ma_calc
  end

  def calc25
    @calc_array = calc(25)[CONST_PRICE]
    render '/moving_average/calc'
  end

  def calc75
    @calc_array = calc(75)[CONST_PRICE]
    render '/moving_average/calc'
  end

  def calc_cross
    #ゴールデンクロスの予兆チェック
    @lookdown_flg = lookdown_check(75, 1500, 60, 10, 4)[0]
    @pre_golden75_flg = lookup_check(75, 1500, 40, 10, 3)[0]
    @golden25_flg = lookup_check(25, 1500, 60, 10, 4)[0]
    @golden_flg, @golden_cross = golden_cross
    #デッドクロスの予兆チェック
    @lookup_flg = lookup_check(75, 1500, 60, 10, 4)[0]
    @pre_dead75_flg = lookdown_check(75, 1500, 40, 10, 3)[0]
    @dead25_flg = lookdown_check(25, 1500, 60, 10, 4)[0]
    @dead_flg, @dead_cross = dead_cross
    #クロスデータをソート
    @cross = []
    unless @golden_flg
      @golden_cross.each do |gc|
        @cross << gc
      end
    end
    unless @dead_flg
      @dc_cross.each do |dc|
        @cross << dc
      end
    end
    @cross = @cross.sort
    render 'moving_average/calc_cross'
  end

  # day: 移動平均の日数
  # data_num: 取得データ数
  # max_count: 予兆チェックの最大数
  # step: 予兆チェックのカウント
  # check: 予兆チェックのリミット
  def lookdown_check(day, data_num, max_count, step, check)
    @ma = nil
    select_ma = nil
    if day = 75
      select_ma = 'ma75'
      @ma = MovingAverage.select(select_ma).where('id >= (?)', -data_num).limit(max_count)
    else day = 25
      select_ma = 'ma25'
      @ma = MovingAverage.select(select_ma).where('id >= (?)', -data_num).limit(max_count)
    end
    lookdown_count = 0
    lookdown_flg = []
    i = 0
    @ma.each do |ma|
      next if ma.id.nil?
      if ma.select_ma.to_f < @ma[i-step].select_ma.to_f
        lookdown_count += 1
      end
      i += 1
    end
    if lookdown_count > check
      lookdown_flg << true
    else
      lookdown_flg << false
    end
    return lookdown_flg, @ma
  end

  def golden_cross
    trash_look, arr_75 = lookup_check(75, 1500, 40, 10, 3)
    trash_gc, arr_25 = lookup_check(25, 1500, 60, 10, 4)
    golden_flg = []
    golden_cross = []
    #前期長期MA下げ目線がプラス で 後期長期MA上げ目線がプラス
    if lookdown_check(75, 1500, 60, 10, 4)[0] && lookup_check(75, 1500, 40, 10, 3)[0]
      arr_75.count.times do |i|
        next if arr_25[1][:id].nil?
        if arr_75[1].ma75 < arr_25[1]['ma25']
          golden_cross << @ma_data[i]
          golden_flg << true
        else
          golden_cross << nil
          golden_flg << false
        end
        puts 'debug:golden_cross='+golden_cross.inspect
      end
    end
    return :golden_flg => golden_flg, :golden_cross => golden_cross
  end

  # day: 移動平均の日数
  # data_num: 取得データ数
  # max_count: 予兆チェックの最大数
  # step: 予兆チェックのカウント
  # check: 予兆チェックのリミット
  def lookup_check(day, data_num, max_count, step, check)
    @ma = nil
    select_ma = nil
    if day = 75
      select_ma = 'ma75'
    else day = 25
      select_ma = 'ma25'
    end
    @ma = MovingAverage.select(select_ma).where('id >= (?)', -data_num).limit(max_count)

    lookup_count = 0
    lookup_flg = []
    i = 0
    @ma.each do |ma|
      next if ma.id.nil?
      if ma.select_ma.to_f > @ma[i-step].select_ma.to_f
        lookup_count += 1
      end
      i += 1
    end
    if lookup_count > check
      lookup_flg << true
    else
      lookup_flg << false
    end
    puts 'debug:lookup_flg='+lookup_flg.inspect
    return lookup_flg, @ma
  end

  def dead_cross
    trash_look, arr_75 = lookup_check(75, 1500, 40, 10, 3)
    trash_gc, arr_25 = lookup_check(25, 1500, 60, 10, 4)
    dead_flg = []
    dead_cross = []
    #前期長期MA下げ目線がプラス で 後期長期MA上げ目線がプラス
    if lookdown_check(75, 1500, 60, 10, 4)[0] && lookup_check(75, 1500, 40, 10, 3)[0]
      arr_75.count.times do |i|
        next if arr_25[1][:id].nil?
        if arr_75[1].ma75 > arr_25[1]['ma25']
          dead_cross << @ma_data[i]
          dead_flg << true
        else
          dead_cross << nil
          dead_flg << false
        end
        puts 'debug:dead_cross='+golden_cross.inspect
      end
    end
    return :dead_flg => dead_flg, :dead_cross => dead_cross
  end

  def set_moving_average_data
    xrp_data = Xrp.all.order(:date)
    calc75 = calc(75)
    calc25 = calc(25)
    #MovingAverage.destroy_all
    recreate_table
    i = 0
    xrp_data.each do |xrp|
      ma = MovingAverage.new
      ma.date = xrp.date
      ma.price = xrp.price
      ma.ma75 = calc75[CONST_PRICE][i]
      ma.ma25 = calc25[CONST_PRICE][i]
      ma.golden_cross = false
      ma.dead_cross = false
      ma.save!
      i += 1
    end
    show_chart
  end

  def show_chart
    ma_data = MovingAverage.all.order(:date).last(200)
    price = ma_data.map{ |ma| ma.price }
    calc75 = ma_data.map{ |ma| ma.ma75 }
    calc25 = ma_data.map{ |ma| ma.ma25 }
    # グラフ（チャート）を作成
    @chart = LazyHighCharts::HighChart.new("graph") do |c|
      c.title(text: "リップル : XRP")
      c.xAxis(categories: ma_data.map{ |ma| ma.date })
      c.yAxis(title: {text: '円'})
      c.series(name: "終値", data: price)
      c.series(name: "移動平均７５", data: calc75)
      c.series(name: "移動平均２５", data: calc25)
    end
    render :show_chart
  end

  require Rails.root.join('db/migrate/20191024184314_create_moving_averages.rb')
  def recreate_table
    mac = CreateMovingAverages.new
    begin
      mac.drop_table :moving_averages
    rescue
    end
    mac.create_table :moving_averages do |t|
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
