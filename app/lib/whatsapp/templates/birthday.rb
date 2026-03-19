class Whatsapp::Templates::Birthday
  def self.build(discount_percentage)
    {
      template_name: self.template_name,
      components: self.components(discount_percentage),
      language: self.language
    }.stringify_keys
  end

  def self.template_name
    "aniversario_v1"
  end

  def self.components(discount_percentage)
    [
      Whatsapp::Components::TextComponent.new(name: "benefit", value: "*#{discount_percentage}% de desconto em sua próxima compra*"),
      Whatsapp::Components::ButtonComponent.new(payload: "birthday_discount")
    ]
  end

  def self.language
    "en"
  end
end
