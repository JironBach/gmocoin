require 'rails_helper'

RSpec.describe GetXrpController, type: :controller do
  context 'get_xrp#indexを表示' do
    it "get #index" do
      get :index
      expect(response.status).to eq(200)
    end
  end

end
