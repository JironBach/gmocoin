class MovingAverageController < ApplicationController
  CONST_PRICE = 1
  CONST_DATE = 0

  def calc(day)
    @ma_data = Xrp.all.order(:date)
    @ma_date = []
    @ma_calc = []
    (@ma_data.count - day).times do |i|
      sum = Xrp.where("id >= (?) " , i).limit(day).sum(:price)
      puts 'debug:sum='+sum.to_s
      @ma_date << @ma_data[i].date
      @ma_calc << sum / day
    end
    return :date => @ma_date, :calc => @ma_calc
  end

  def calc25
    @calc_array = calc(25)
    render '/moving_average/calc'
  end

  def calc75
    @calc_array = calc(75)
    render '/moving_average/calc'
  end

  def calc_cross
    #ゴールデンクロスの予兆チェック
    @lookdown_flg = lookdown_check(75, 1500, 60, 10, 4)[:lookdown_flg]
    @pre_golden75_flg = lookup_check(75, 1500, 40, 10, 3)[:lookup_flg]
    @golden25_flg = lookup_check(25, 1500, 60, 10, 4)[:lookup_flg]
    @golden_flg, @golden_cross = golden_cross
    #デッドクロスの予兆チェック
    @lookup_flg = lookup_check(75, 1500, 60, 10, 4)[:up_flg]
    @pre_dead75_flg = lookdown_check(75, 1500, 40, 10, 3)[:lookdown_flg]
    @dead25_flg = lookdown_check(25, 1500, 60, 10, 4)[:lookdown_flg]
    @dead_flg, @dead_cross = dead_cross
    #クロスデータをソート
    puts 'debug:golden='+@golden_cross.inspect
    puts 'debug:dead='+@dead_cross.inspect
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
    puts 'debug:@cross='+@cross.inspect
    render 'moving_average/calc_cross'
  end

  # day: 移動平均の日数
  # data_num: 取得データ数
  # max_count: 予兆チェックの最大数
  # step: 予兆チェックのカウント
  # check: 予兆チェックのリミット
  def lookdown_check(day, data_num, max_count, step, check)
    calc_array = calc(day)[-data_num, data_num]
    lookdown_count = 0
    lookdown_flg = []
    step.step(max_count, step) { |i|
      if (calc_array[i].split(',')[0][CONST_PRICE].to_f - calc_array[i-step].split(',')[0][CONST_PRICE].to_f) < 0
        lookdown_count += 1
      end
      if lookdown_count > check
        lookdown_flg << true
      else
        lookdown_flg << false
      end
    }
    puts 'debug:lookdown_count='+lookdown_flg.count.inspect
    return :lookdown_flg => lookdown_flg, :calc_array => calc_array
  end

  def golden_cross
    trash_look, arr_75 = lookup_check(75, 1500, 40, 10, 3)
    trash_gc, arr_25 = lookup_check(25, 1500, 60, 10, 4)
    golden_flg = []
    golden_cross = []
    #前期長期MA下げ目線がプラス で 後期長期MA上げ目線がプラス
    if lookdown_check(75, 1500, 60, 10, 4)[0] && lookup_check(75, 1500, 40, 10, 3)[0]
      arr_75.count.times do |i|
        if arr_75[i][1] < arr_25[i][1]
          golden_cross << @ma_data[i].inspect
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
    calc_array = calc(day)[-data_num, data_num]
    lookup_count = 0
    lookup_flg = []
    step.step(max_count, step) { |i|
      if (calc_array[i].split(',')[0][CONST_PRICE].to_f - calc_array[i-step].split(',')[0][CONST_PRICE].to_f) > 0
        lookup_count += 1
      end
      if lookup_count > check
        lookup_flg << true
      else
        lookup_flg << false
      end
    }
    puts 'debug:lookup_count='+lookup_flg.count.inspect
    return :lookup_flg => lookup_flg, :calc_array => calc_array
  end

  def dead_cross
    trash_lookup, arr_75 = lookup_check(75, 1500, 40, 10, 3)
    trash_cross, arr_25 = lookup_check(25, 1500, 60, 10, 4)
    dead_flg = []
    dead_cross = []
    #前期長期MA上げ目線がプラス で 後期長期MA下げ目線がプラス
    if lookup_check(75, 1500, 60, 10, 4)[0] && lookdown_check(75, 1500, 40, 10, 3)[0]
      arr_75.count.times do |i|
        if arr_75[i][1] > arr_25[i][1]
          dead_cross << @ma_data[i].inspect
          dead_flg << true
        else
          dead_cross << nil
          dead_flg << false
        end
      end
      puts 'debug:dead_count='+dead_cross.count.inspect
    end
    return :dead_flg => dead_flg, :dead_cross => dead_cross
  end

  def set_moving_average_data
    xrp_data = Xrp.all.order(:date)
    calc75 = calc(75)
    calc25 = calc(25)
    MovingAverage.destroy_all
    i = 0
    xrp_data.each do |xrp|
      ma = MovingAverage.new
      ma.date = xrp.date
      puts 'debug:date='+xrp.date.inspect
      ma.price = xrp.price
      puts 'debug:calc75='+calc75[:price].inspect
      ma.ma75 = calc75[:price].to_f
      if tmp_calc25 = calc25.find {|item| item[CONST_DATE] == xrp.date }
        ma.ma25 = tmp_calc25[:price].to_f
      end
      ma.golden_cross = false
      ma.dead_cross = false
      ma.save!
      i += 1
    end
    show_chart
  end

  def show_chart
    ma_data = MovingAverage.all.order(:date).last(1000)
    calc75 = ma_data.map{ |ma| ma.ma75 }
    calc25 = ma_data.map{ |ma| ma.ma25 }
    # グラフ（チャート）を作成
    @chart = LazyHighCharts::HighChart.new("graph") do |c|
      c.title(text: "xrp")
      c.xAxis(categories: ma_data.map{ |ma| ma.date })
      c.yAxis(title: {text: '円'})
      c.series(name: "移動平均７５", data: calc75)
      c.series(name: "移動平均２５", data: calc25)
    end
    render :show_chart
  end

end
