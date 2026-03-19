Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("CORS_ORIGINS", "http://localhost:3001").split(";")
    resource "*", headers: :any, methods: [ :get, :post, :patch, :put, :delete ], credentials: true

    origins "*"
    resource "/up", headers: :any, methods: [ :get ], credentials: false
  end
end
