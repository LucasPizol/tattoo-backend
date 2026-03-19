class PhoneService
  def self.normalize(phone)
    normalized_value = phone.gsub(/[^0-9]/, "")

    if normalized_value.length == 10
      "559#{normalized_value}"
    elsif normalized_value.length == 11
      "55#{normalized_value}"
    else
      normalized_value
    end
  end
end
