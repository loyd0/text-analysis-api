Rails.application.routes.draw do
  scope :api do
    post 'register', to: 'authentications#register'
    post 'login', to: 'authentications#login'
    resources :projects
    resources :users
  end
end
