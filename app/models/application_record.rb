class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  attr_accessor :total_pages

  def self.ransackable_attributes(auth_object = nil)
    column_names
  end

  def self.ransackable_associations(auth_object = nil)
    reflect_on_all_associations.map(&:name).map(&:to_s)
  end

  scope :paginate, ->(page, per_page = 10) {
    page = [ (page&.to_i || 0), 1 ].max
    per_page = [ (per_page&.to_i || 0), 10 ].max

    count = self.count

    if count.is_a?(Hash)
      count = count.values.sum
    end

    define_singleton_method(:total_count) { count }
    define_singleton_method(:total_pages) { (count / per_page.to_f).ceil }
    define_singleton_method(:current_page) { page }

    offset((page - 1) * per_page).limit(per_page)
  }
end
