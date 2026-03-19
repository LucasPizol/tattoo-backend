# frozen_string_literal: true

class Instagram::Client::Graph < Instagram::Client
  def call
    raise NotImplementedError, "Graph client uses specific methods (me, create_short_token, etc.)"
  end
end
