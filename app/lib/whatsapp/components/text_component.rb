class Whatsapp::Components::TextComponent
  include ActiveModel::Validations

  attr_accessor :name, :value

  validates :name, presence: true
  validates :value, presence: true

  def initialize(name:, value: nil)
    @name = name
    @value = value
  end

  def to_h
    { type: "text", parameter_name: name, text: value }
  end
end
