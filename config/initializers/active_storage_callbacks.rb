Rails.application.config.to_prepare do
  ActiveStorage::Attachment.class_eval do
    after_destroy :after_attachment_destroy

    private

    def after_attachment_destroy
      FileUtils.rm_rf(Rails.root.join("public", "thumbnails", id.to_s))
    end
  end
end
