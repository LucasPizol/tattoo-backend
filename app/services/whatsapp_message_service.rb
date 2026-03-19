class WhatsappMessageService
  def initialize(message)
    @message = message
  end

  def content
    @message[:content].presence || false
  end

  def from
    @message[:from].presence || false
  end

  def build_response
    {
      content: content,
      from: from
    }
  end
end
