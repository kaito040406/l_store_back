Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  namespace :api do
    namespace :v1 do
      resources :test, only: %i[index]
      # namespace :user do


      # end
      resources :messages
      resources :tokens

      resources :tokens, param: :access_id do
        resources :line_costmers, only: [:create]
      end

      resources :tokens, param: :user_id do
        resources :line_costmers, except: [:create]
      end

      resources :line_costmers do
        resources :chats
      end
      

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
