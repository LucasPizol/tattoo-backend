class Instagram::SynchronizeAccountsJob < ApplicationJob
  def perform
    Instagram::Account.find_each do |account|
      Instagram::SynchronizeMediaJob.perform_async(account.id)
    end
  end
end
