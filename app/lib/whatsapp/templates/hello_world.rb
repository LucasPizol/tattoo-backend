class Whatsapp::Templates::HelloWorld
  def self.build
    {
      template_name: self.template_name,
      components: self.components,
      language: self.language
    }.stringify_keys
  end

  def self.template_name
    "hello_world"
  end

  def self.components
    []
  end

  def self.language
    "en_US"
  end
end
