require 'rails_helper'

RSpec.describe IndexController, type: :controller do
  #include LoginHelper

  #let(:user) { FactoryBot.create(:user, name: 'michael') }

  context 'index#indexを表示' do
    it "get #index" do
      get :index
      expect(response.status).to eq(200)
    end
  end

end
