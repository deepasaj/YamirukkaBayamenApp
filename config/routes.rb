Rails.application.routes.draw do
  root 'sambavams#index'
  get 'plot' => 'sambavams#plot'
  get 'safe_routes' => 'sambavams#safe_routes'
end
