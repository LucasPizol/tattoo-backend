class Whatsapp::Templates::OrderConfirmation
  def self.build
    {
      template_name: self.template_name,
      components: self.components
    }.stringify_keys
  end

  def self.template_name
    "order_confirmation"
  end

  def self.components
    []
  end
end
