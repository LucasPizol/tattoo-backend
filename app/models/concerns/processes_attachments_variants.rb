module ProcessesAttachmentsVariants
  extend ActiveSupport::Concern

  included do
    after_commit :enqueue_process_variants_job, on: [ :create, :update ]
  end

  private

  def enqueue_process_variants_job
    return unless has_attachments_with_named_variants?
    return unless has_any_attachments?

    ProcessActiveStorageVariantsJob.perform_async(self.id, self.class.name)
  end

  def has_attachments_with_named_variants?
    self.class.reflect_on_all_attachments.any? { |r| r.named_variants.any? }
  end

  def has_any_attachments?
    self.class.reflect_on_all_attachments.any? { |r| send(r.name).attached? }
  end
end
