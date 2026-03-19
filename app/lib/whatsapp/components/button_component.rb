class Whatsapp::Components::ButtonComponent
  include ActiveModel::Validations

  attr_accessor :payload, :url_text, :index

  def initialize(payload: nil, url_text: nil)
    @payload = payload
    @url_text = url_text
  end

  def sub_type
    payload.present? ? "quick_reply" : "url"
  end

  def to_h
    if payload.present?
      { type: "payload", payload: payload }
    elsif url_text.present?
      { type: "text", text: url_text }
    else
      {}
    end
  end
end
