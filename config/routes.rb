Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  namespace :api do
    namespace :v1 do
      resources :test, only: %i[index]
      # namespace :user do

      resources :users, only: [:show]

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
        resources :l_groups do
          resources :line_customer_l_groups, only: [:create]
        end
      end

      resources :l_groups, only: [:create]

      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations: 'api/v1/auth/registrations'
      }


      namespace :auth do
        resources :sessions, only: %i[index]
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
