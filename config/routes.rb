require 'api_constraints'

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount SabisuRails::Engine => "/sabisu_rails"
  devise_for :users

  devise_scope :user do
    get "/" => "devise/sessions#new"
  end

  root 'devise/sessions#new'
  
  # Api definition
  namespace :api, defaults: { format: :json }, constraints: { subdomain: 'api' }, path: '/'  do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      # We are going to list our resources here
      resources :users, :only => [:show, :create, :update, :destroy, :index]
      resources :sessions, :only => [:create, :destroy]
    end
  end
end
