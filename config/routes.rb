Rails.application.routes.draw do

  devise_for :admins,  controllers: { sessions: 'admins/sessions', registrations: 'admins/registrations' }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'rooms#index'

  resources :admins do 
    resources :roles
    member do
      get :approve
    end
  end


  resources :rooms 
  resources :coins

  namespace :api do
    mount API::V1::Base => '/'
  end

  mount GrapeSwaggerRails::Engine => '/swagger'


end
