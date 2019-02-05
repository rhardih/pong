require 'resque'
require 'resque/scheduler/server'

Rails.application.routes.draw do
  root "checks#index"

  resources :checks

  mount Resque::Server.new, at: '/resque'
end
