require 'rails_helper'

RSpec.describe SetXrpController, type: :controller do
  context 'set_xrp#set_xrp' do
    it "get #set_xrp" do
      post :set_xrp, params: {csv_file: Rails.root.join('csv', 'xrp_20190101.csv')}
      expect(response.status).to eq(302)
    end
  end

end
