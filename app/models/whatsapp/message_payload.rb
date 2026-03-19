class Whatsapp::MessagePayload
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :from, :string
  attribute :to, :string
  attribute :phone_number_id, :string
  attribute :body, :string
  attribute :payload, :string
  attribute :type, :string
  attribute :id, :string
  attribute :sent_at, :datetime
  attribute :contact_name, :string
  attribute :status, :string

  validates :from, presence: true
  validates :to, presence: true
  validates :phone_number_id, presence: true
  validates :body, presence: true, allow_blank: true
  validates :type, presence: true
  validates :id, presence: true
  validates :sent_at, presence: true
  validates :status, presence: true

  def self.from_json(json)
    begin
      parsed_json = json.with_indifferent_access

      value = parsed_json[:entry].first[:changes].first[:value]

      to = value[:metadata][:display_phone_number]
      contact_name = value[:contacts].first[:profile][:name]
      from = value[:contacts].first[:wa_id]

      message = value[:messages]&.first

      if message.present?
        body = message.dig(:text, :body) || message.dig(:button, :text)
        payload = message.dig(:button, :payload)
        timestamp = message[:timestamp]
        message_id = message[:id]
        phone_number_id = value[:metadata][:phone_number_id]

        return new(
          from: from,
          to: to,
          body: body,
          payload: payload,
          id: message_id,
          sent_at: Time.at(timestamp.to_i),
          contact_name: contact_name,
          phone_number_id: phone_number_id,
          status: "received"
        )
      end

      statuses = value[:statuses].first

      if statuses.present?
        status = statuses[:status].downcase
        timestamp = statuses[:timestamp]
        message_id = statuses[:id]
        phone_number_id = value[:metadata][:phone_number_id]

        return new(
          from: from,
          to: to,
          body: "",
          payload: "",
          id: message_id,
          sent_at: Time.at(timestamp.to_i),
          contact_name: contact_name,
          phone_number_id: phone_number_id,
          status: status
        )
      end
    rescue => e
      Rails.logger.error("Error parsing message payload: #{e.message}")
      return nil
    end

    raise "Message payload not supported"
  end

  def self.idempotency_key(json)
    parsed_json = json.with_indifferent_access

    value = parsed_json[:entry].first[:changes].first[:value]

    return value[:messages].first[:id] if value[:messages].present?

    return "#{value[:statuses].first[:id]}-#{value[:statuses].first[:status].downcase}" if value[:statuses].present?

    raise "Idempotency key not supported"
  end

  def to_h
    {
      from: from,
      to: to,
      body: body,
      payload: payload,
      id: id,
      sent_at: sent_at,
      contact_name: contact_name,
      phone_number_id: phone_number_id,
      status: status
    }
  end
end
