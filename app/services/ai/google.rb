# frozen_string_literal: true


class Ai::Google < Ai::Base
  TIMES_TO_ATTEMPT = 3

  def initialize(user:, model: "gemini-2.5-flash")
    @url = "#{ENV.fetch('GEMINI_AI_URL', nil)}"
    @user = user
    @model = model
  end

  def generate_text(prompt: nil, images: nil, videos: nil, system_prompt: "")
    raise(CustomException, "Prompt or images or videos is required") if images.blank? && videos.blank? && prompt.nil?

    contents = "#{system_prompt}\n#{prompt}"

    params = {}

    uri = URI("#{@url}/v1beta/models/#{@model}:generateContent")
    uri.query = URI.encode_www_form(params) if params.present?

    parts = []

    parts << { text: contents }

    images.each do |image|
      image_data = if image.respond_to?(:blob)
                     image.blob.download
      elsif image.respond_to?(:read)
                     image.rewind if image.respond_to?(:rewind)
                     image.read
      else
                     image
      end

      parts << {
        inlineData: {
          data: Base64.strict_encode64(image_data),
          mimeType: image.respond_to?(:blob) ? image.blob.content_type : image.content_type
        }
      }
    end

    response = nil

    attempt = 0

    response = Faraday.post(uri.to_s) do |req|
      req.body = {
        contents: [
          {
            parts: parts
          }
        ]
      }.to_json

      req.options.timeout = 300
      req.options.open_timeout = 20

      req.headers["Content-Type"] = "application/json"
      req.headers["x-goog-api-key"] = ENV.fetch("GEMINI_AI_API_KEY", nil)
    end

    raise(CustomException, response.body) unless response.success?

    json_response = JSON.parse(response.body, symbolize_names: true)
    message = json_response[:candidates].first[:content][:parts].first[:text]

    raise(CustomException, "No response from Google AI") if message.blank?

    formatted_response = {
      message: message.strip,
      metadata: {
        prompt_tokens: json_response[:usageMetadata][:promptTokenCount],
        candidate_tokens: json_response[:usageMetadata][:candidatesTokenCount],
        model: json_response[:modelVersion]
      }
    }

    formatted_response[:message]
  end

  def generate_json(prompt: nil, image: nil, system_prompt: "")
    raise(CustomException, "Prompt or image is required") if image.nil? && prompt.nil?

    text = generate_text(prompt: prompt, image: image, system_prompt: system_prompt)

    JSON.parse(text.gsub("```json", "").gsub("```", "").strip)
  rescue JSON::ParserError
    raise(CustomException, "Resposta inválida")
  end
end
