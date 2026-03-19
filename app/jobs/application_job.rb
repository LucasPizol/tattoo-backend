class ApplicationJob
  include ClassLogger
  include Sidekiq::Job
end
