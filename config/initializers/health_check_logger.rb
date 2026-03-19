class HealthcheckLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["PATH_INFO"] == "/up"
      Rails.logger.warn(
        "[HEALTHCHECK] host=#{env['HTTP_HOST']} scheme=#{env['rack.url_scheme']} remote_ip=#{env['REMOTE_ADDR']} path=#{env['PATH_INFO']} method=#{env['REQUEST_METHOD']}"
      )
    end

    @app.call(env)
  end
end

Rails.application.config.middleware.insert_before 0, HealthcheckLogger
