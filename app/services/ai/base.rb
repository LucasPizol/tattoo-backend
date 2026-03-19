# frozen_string_literal: true


class Ai::Base
  def initialize(user:)
    @user = user
  end

  def generate_text(prompt: nil, image: nil, video: nil, system_prompt: "")
   raise NotImplementedError, "Subclasses must implement this method"
  end

  def generate_json(prompt: nil, image: nil, system_prompt: "")
    raise NotImplementedError, "Subclasses must implement this method"
  end
end
