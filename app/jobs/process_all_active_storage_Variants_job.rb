class ProcessAllActiveStorageVariantsJob < ApplicationJob
  queue_as :default

  def perform(record_class)
    new_record_class = record_class.constantize.new

    begin
      new_record_class.send(:has_attachments_with_named_variants?)
    rescue NoMethodError
      Rails.logger.error "Record class #{record_class} does not have has_attachments_with_named_variants?"
      return
    end

    record_class.constantize.find_each do |record|
      ProcessActiveStorageVariantsJob.perform_async(record.id, record_class) if record.send(:has_attachments_with_named_variants?)
    end
  end
end
