require 'rails_helper'

RSpec.describe MovingAverageController, type: :controller do
  context 'moving_average#calc25を表示' do
    it "get #calc25" do
      get :calc25
      expect(response.status).to eq(200)
    end
  end

  context 'moving_average#calc75' do
    it "get #calc75" do
      get :calc75
      expect(response.status).to eq(200)
    end
  end

  context 'moving_average#calc75' do
    it "get #set_moving_average_data" do
      get :set_moving_average_data
      expect(response.status).to eq(200)
    end
  end

  context 'moving_average#calc_crossを表示' do
    it "get #calc_cross" do
      get :calc_cross
      expect(response.status).to eq(200)
    end
  end

end
