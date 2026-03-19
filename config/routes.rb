require "sidekiq/web"
require "sidekiq-scheduler/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  get "catalogs/client", to: "catalogs/client#show"
  get "catalogs/internal", to: "catalogs/internal#show"

  get "/up", to: proc { [ 200, { "Content-Type" => "text/plain", "Cache-Control" => "no-cache, no-store, must-revalidate" }, [ "OK" ] ] }
  get "/healthcheck", to: proc { [ 200, { "Content-Type" => "text/plain", "Cache-Control" => "no-cache, no-store, must-revalidate" }, [ "OK" ] ] }

  namespace :web, defaults: { format: :json } do
    namespace :api do
      resources :products, only: [ :index, :show ], param: :slug do
        member do
          get :recommendation
        end

        collection do
          get :materials
          get :tags
        end
      end

      resources :cart_products, only: [ :index, :create, :update, :destroy ] do
        collection do
          get :quantity
        end
      end
      resources :home, only: [ :index ] do
        collection do
          get :tags
          get :featured_products
          get :latest_products
          get :carousel_products
          get :types
        end
      end
      resources :checkout, only: [ :update ]
      resources :orders, only: [ :index, :create, :show, :update ] do
        resource :shipping, only: [ :create ]

        member do
          resources :shipping_estimations, only: [ :create ], controller: "orders/shipping_estimations"
          resources :shippings, only: [ :create ], controller: "orders/shippings"
        end
      end
      resources :addresses, only: [ :index, :create, :update ]
      resource :sessions, only: [ :destroy ], controller: "sessions" do
        collection do
          post :login
          post :register
          get :me
        end
      end
    end
  end

  namespace :api, defaults: { format: :json } do
    resources :registrations, only: %i[create]

    scope :auth do
      post "google", to: "google_auth#authenticate"
      post "google/complete", to: "google_auth#complete_registration"
    end

    resources :roles do
      collection do
        get :available_permissions
      end
      resource :permissions, only: %i[update], controller: "permissions"
    end
    resources :user_invites, only: [ :index, :create ] do
      collection do
        post :accept, path: "accept"
      end

      member do
        post :resend, path: "resend"
      end
    end

    resource :sessions, only: %i[ show create destroy ] do
      member do
        post :refresh
      end
    end
    namespace :mercado_pago do
      resources :terminals, only: %i[ index create ]
    end
    namespace :instagram do
      resources :posts, only: %i[ index create show update destroy ] do
        member do
          post :publish
        end
      end
      resources :authentications, only: %i[ index ]
      resources :redirects, only: %i[ index ]
      resources :accounts, only: %i[ index destroy ]
      resources :posts, only: %i[ create ] do
        resource :generate_content, only: %i[ create ], controller: "posts/generate_content"
      end
      resource :dashboard, only: %i[ show ], controller: "dashboard"
      resources :comments, only: %i[ index ]
    end
    resources :clients do
      resources :indications, only: %i[ index ], controller: "clients/indications"
    end
    resources :tags
    resources :materials
    resources :products
    resources :catalogs, only: %i[ index show ]
    resources :payment_methods
    resources :sale_messages, only: %i[ index create destroy ]
    resources :notifications, only: %i[ index ]
    resources :users, only: %i[ index update ]
    resources :contracts, only: %i[ index show ] do
      collection do
        get :pending
      end
      member do
        post :sign
      end
    end
    resources :addresses, only: %i[ destroy ]
    resources :stocks, only: %i[ create ]
    namespace :whatsapp do
      resource :connection, only: %i[show create destroy]
    end

    namespace :webhook do
      namespace :mercado_pago do
        resources :payments, only: %i[ create ]
      end
      namespace :whatsapp do
        resources :handlers, only: %i[ index create ]
      end
      namespace :instagram do
        resources :main, only: %i[ index create ], controller: "main"
      end
      namespace :correios do
        resources :shipments, only: %i[ create ]
      end
    end

    resources :user_comissions, only: %i[ create ]

    resources :attached_images, only: %i[ destroy ]

    resources :orders do
      resources :attached_images, only: %i[ index create destroy ], controller: "orders/attached_images"
      resource :apply_birth_date_discount, only: %i[ update ], controller: "orders/apply_birth_date_discount"
      resources :comissions, only: %i[ create update destroy ]
      resources :order_payment_methods, only: %i[ create update destroy ]
      member do
        put :reopen, path: "reopen"
      end
    end

    resources :product_types, only: %i[ index ]
    resources :order_products, only: %i[ create update destroy ] do
      collection do
        post :bulk_insert
      end
    end
    resources :stock_movements, only: %i[ index show create destroy ]
    resources :responsibles, only: %i[ create update destroy ]
    resources :images, only: %i[ destroy ]
    resources :calendar_events, only: %i[ index show create update destroy ]
    resources :notes, only: %i[ index show create update destroy ]
    resources :campaigns, only: %i[ index show create update destroy ]
    resources :indications, only: %i[ index ]

    namespace :dashboard do
      resources :order_counts, only: %i[ index ]
      resources :values_evolutions, only: %i[ index ]
      resources :product_sells, only: %i[ index ]
      resources :product_types, only: %i[ index ]
      resources :tags, only: %i[ index ]
      resources :materials, only: %i[ index ]
      resources :client_sells, only: %i[ index ]
      resources :summaries, only: %i[ index ]
      resources :sellers, only: %i[ index ] do
        collection do
          put :adjust_sellers
          put :adjust_shipment_received_value
        end
      end
      resources :age, only: %i[ index ]
      resources :reports, only: %i[ index ]
      resources :comissions, only: %i[ index ]
    end

    resources :raffles, only: %i[ index show create destroy ]

    resource :company_configs, only: %i[ update ]

    namespace :company_config do
      resource :apply_price, only: %i[ create ]
    end
  end
end
