# == Schema Information
#
# Table name: raffles
#
#  id                :bigint           not null, primary key
#  description       :text
#  filters           :jsonb            not null
#  name              :string           not null
#  primary_count     :integer          default(1), not null
#  secondary_count   :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  company_id        :integer          not null
#  instagram_post_id :bigint
#
# Indexes
#
#  index_raffles_on_company_id         (company_id)
#  index_raffles_on_instagram_post_id  (instagram_post_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (instagram_post_id => instagram_posts.id)
#
class Raffle < ApplicationRecord
  belongs_to :company
  has_many :raffle_clients, dependent: :destroy
  has_many :clients, through: :raffle_clients

  belongs_to :instagram_post, optional: true, class_name: "Instagram::Post", foreign_key: :instagram_post_id, primary_key: :id

  validates :name, presence: true
  validates :primary_count, numericality: { greater_than: 0 }
  validates :secondary_count, numericality: { greater_than_or_equal_to: 0 }

  def perform_draw!
    if instagram_post.present?
      initial_excluded_usernames = [ instagram_post.account.ig_username ]

      primary_winners = draw_unique_instagram_winners(primary_count, initial_excluded_usernames)
      excluded = primary_winners.map(&:username)
      secondary_winners = draw_unique_instagram_winners(secondary_count, excluded + initial_excluded_usernames)

      ActiveRecord::Base.transaction do
        raffle_clients.destroy_all

        primary_winners.each_with_index do |comment, index|
          raffle_clients.create!(instagram_comment: comment, raffle_type: :primary, position: index + 1)
        end

        secondary_winners.each_with_index do |comment, index|
          raffle_clients.create!(instagram_comment: comment, raffle_type: :secondary, position: index + 1)
        end
      end

      return true
    end

    eligible_clients = find_eligible_clients
    shuffled = eligible_clients.shuffle

    primary_winners = shuffled.first(primary_count)
    remaining = shuffled - primary_winners
    secondary_winners = remaining.first(secondary_count)

    ActiveRecord::Base.transaction do
      raffle_clients.destroy_all

      primary_winners.each_with_index do |client, index|
        raffle_clients.create!(client: client, raffle_type: :primary, position: index + 1)
      end

      secondary_winners.each_with_index do |client, index|
        raffle_clients.create!(client: client, raffle_type: :secondary, position: index + 1)
      end
    end
  end

  private

  def draw_unique_instagram_winners(count, excluded_usernames)
    winners = []
    excluded = excluded_usernames.dup

    count.times do
      comment = instagram_post.comments
        .where.not(username: [ nil, "" ] + excluded)
        .order(Arel.sql("RANDOM()"))
        .limit(1)
        .first
      break unless comment

      winners << comment
      excluded << comment.username
    end

    winners
  end

  def find_eligible_clients
    scope = company.clients.joins(:orders).where(orders: { status: :paid })

    if filters["start_date"].present? && filters["end_date"].present?
      start_date = Date.parse(filters["start_date"])
      end_date = Date.parse(filters["end_date"])
      scope = scope.where(orders: { paid_at: start_date.beginning_of_day..end_date.end_of_day })
    end

    if filters["product_ids"].present?
      product_ids = filters["product_ids"]
      scope = scope.joins(orders: :order_products).where(order_products: { product_id: product_ids })
    end

    if filters["min_order_value"].present?
      min_value_subcents = (filters["min_order_value"].to_f * 100).to_i
      scope = scope.where("orders.product_values_subcents >= ?", min_value_subcents)
    end

    scope.distinct
  end
end
