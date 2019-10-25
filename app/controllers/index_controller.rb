class IndexController < ApplicationController
  def index
    @csv_files = []
    Dir.glob(Rails.root.join('csv', "xrp*.csv")) { |f| p f
      @csv_files << f
    }
  end

end
