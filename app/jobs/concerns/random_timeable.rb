module RandomTimeable
  extend ActiveSupport::Concern

  private

  def random_minutes(index)
    base = index * 5

    (base + rand(-2..2)).minutes
  end
end
