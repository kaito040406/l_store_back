Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  namespace :api do
    namespace :v1 do
      resources :test, only: %i[index]
      # namespace :user do

      resources :users, only: [:show]

      get '/users/:id/last_seven_day', to: 'users#last_seven_day'

      get '/users/:id/last_seven_week', to: 'users#last_seven_week'

      get '/users/:id/last_seven_month', to: 'users#last_seven_month'

      get '/users/:id/follow_data', to: 'users#get_follow_data'

      post '/users/:id/create_subscription', to: 'users#create_subscription'

      # end
      resources :messages
      resources :tokens

      resources :tokens, param: :access_id do
        resources :line_customers, only: [:create]
      end

      resources :tokens, param: :user_id do
        resources :line_customers, except: [:create]
      end

      resources :line_customers do
        resources :chats
        resources :memos
        resources :line_customer_l_groups
      end

      resources :l_groups

      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations: 'api/v1/auth/registrations'
      }


      namespace :auth do
        resources :sessions, only: %i[index]
      end
    end
  end
  # mount StripeEvent::Engine, at: '/webhooks/stripe'
  post '/webhooks/stripe', to: 'stripe_event/webhooks#event'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
