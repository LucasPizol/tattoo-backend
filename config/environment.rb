# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
begin
  Rails.application.initialize!
rescue => e
  puts "Error initializing Rails application: #{e.message}"
  puts "Backtrace: #{e.backtrace.join("\n")}"
  raise e
end
