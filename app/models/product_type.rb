class ProductType
  def self.as_hash
    {
      ring: { label: "Argola", color: "red" },
      ferradura: { label: "Ferradura", color: "blue" },
      captive: { label: "Captive", color: "green" },
      barbell: { label: "Barbell", color: "yellow" },
      clicker: { label: "Clicker", color: "purple" },
      microdermal: { label: "Microdermal", color: "orange" },
      twister: { label: "Twister", color: "pink" },
      labret: { label: "Labret", color: "brown" },
      nostril: { label: "Nostril", color: "gray" },
      banana_bell: { label: "Banana Bell", color: "yellow" },
      nostril_ring: { label: "Nostril Argola", color: "gray" },
      barbell_curved: { label: "Barbell Curvo", color: "yellow" },
      brinco: { label: "Brinco", color: "" }
    }
  end

  def self.as_array
    self.as_hash.map { |key, value| { key: key, label: value[:label], color: value[:color] } }
  end

  def self.find(key)
    return nil unless key.present?
    return nil unless self.as_hash.key?(key.to_sym)

    self.as_hash[key.to_sym]
  end
end
