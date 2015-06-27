Rails.application.routes.draw do
  root 'sambavams#index'
  get 'plot' => 'sambavams#plot'
end
