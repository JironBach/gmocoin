require 'fileutils'

class GetXrpController < ApplicationController
  def index
    @prices = Xrp.all.order(:date)
  end

end
