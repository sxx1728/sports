Rails.application.routes.draw do

  devise_for :admins,  controllers: { sessions: 'admins/sessions', registrations: 'admins/registrations' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'admins#index'

  resources :admins do 
    resources :roles
    member do
      get :approve
    end
  end


  resources :chainly_configs

  resources :users do
    member do
      patch :gen_code
      patch :enable_code
      patch :disable_code
    end
  end
 
  resources :kycs do
    member do
      patch :accept
      patch :reject
    end
  end

  namespace :api do
    mount API::V1::Base => '/'
  end

  mount GrapeSwaggerRails::Engine => '/swagger'


end
