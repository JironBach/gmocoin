require 'csv'

class SetXrpController < ApplicationController
  protect_from_forgery

  def set_xrp
    read_csv
    redirect_to '/get_xrp/index'
  end

  def read_csv
    csv_file = params[:csv_file]
    CSV.foreach(csv_file, headers: true, liberal_parsing: true) do |data|
      insert_xrp(data)
    end
  end

  def insert_xrp(xrp_csv)
    date = xrp_csv[0].to_s
    year = date.split(",")[1]
    month = date.split(",")[0].split(' ')[0]
    day = date.split(",")[0].split(' ')[1]
    #Xrp.destroy_all
    saved_date = Xrp.where(date: Date.parse(year.to_s+'-'+get_month(month)+'-'+day)).first
    if saved_date.nil?
      xrp = Xrp.new
      xrp.date = Date.parse(year.to_s+'-'+get_month(month)+'-'+day.to_s)
      xrp.price = xrp_csv[2].to_f
      xrp.open = xrp_csv[3].to_f
      xrp.high = xrp_csv[4].to_f
      xrp.low = xrp_csv[5].to_f
      xrp.change = xrp_csv[6].to_s.slice(0, xrp_csv[6].to_s.index('%')).to_f
      xrp.save!
    end
  end

  def get_month(month)
    if month == 'Jan'
      return '01'
    elsif month == 'Feb'
      return '02'
    elsif month == 'Mar'
      return '03'
    elsif month == 'Apr'
      return '04'
    elsif month == 'May'
      return '05'
    elsif month == 'Jun'
      return '06'
    elsif month == 'Jul'
      return '07'
    elsif month == 'Aug'
      return '08'
    elsif month == 'Sep'
      return '09'
    elsif month == 'Oct'
      return '10'
    elsif month == 'Nov'
      return '11'
    else
      return '12'
    end
  end

end
