Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'index#index'
  get '/get_xrp/index' => 'get_xrp#index'
  post '/set_xrp_xrp' => 'set_xrp#set_xrp'
  get '/moving_average/calc25' => 'moving_average#calc25'
  get '/moving_average/calc75' => 'moving_average#calc75'
  get '/moving_average/calc_cross' => 'moving_average#calc_cross'
  get '/moving_average/set_moving_average_data' => 'moving_average#set_moving_average_data'
  get '/moving_average/show_chart' => 'moving_average#show_chart'
end
