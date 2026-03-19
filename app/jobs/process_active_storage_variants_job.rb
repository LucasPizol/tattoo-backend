class ProcessActiveStorageVariantsJob < ApplicationJob
  queue_as :default

  def perform(record_id, record_class)
    record = record_class.constantize.find(record_id)

    record.class.reflect_on_all_attachments.each do |reflection|
      next if reflection.named_variants.empty?

      attachments = fetch_attachments(record, reflection)

      attachments.each do |attachment|
        next unless attachment.blob.variable?

        reflection.named_variants.each_key do |variant_name|
          attachment.variant(variant_name).processed
        end
      end
    end
  end

  private

  def fetch_attachments(record, reflection)
    attached = record.send(reflection.name)

    case reflection.macro
    when :has_one_attached
      attached.attached? ? [ attached ] : []
    when :has_many_attached
      attached.to_a
    else
      []
    end
  end
end
