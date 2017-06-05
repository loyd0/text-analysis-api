Rails.application.routes.draw do
  post 'register', to: 'authentications#register'
  post 'login', to: 'authentications#login'
  scope :api do
    resources :projects
    resources :users
  end
end
