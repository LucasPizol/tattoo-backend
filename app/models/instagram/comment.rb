# == Schema Information
#
# Table name: instagram_comments
#
#  id                   :bigint           not null, primary key
#  text                 :text             not null
#  username             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  ig_comment_id        :string           not null
#  instagram_account_id :integer          not null
#  instagram_comment_id :integer
#  instagram_post_id    :integer          not null
#
# Indexes
#
#  index_instagram_comments_on_instagram_account_id  (instagram_account_id)
#  index_instagram_comments_on_instagram_comment_id  (instagram_comment_id)
#  index_instagram_comments_on_instagram_post_id     (instagram_post_id)
#
# Foreign Keys
#
#  fk_rails_...  (instagram_account_id => instagram_accounts.id)
#  fk_rails_...  (instagram_comment_id => instagram_comments.id)
#  fk_rails_...  (instagram_post_id => instagram_posts.id)
#
class Instagram::Comment < ApplicationRecord
  self.table_name = "instagram_comments"

  has_many :raffle_clients, dependent: :destroy, inverse_of: :instagram_comment, class_name: "RaffleClient", foreign_key: :instagram_comment_id, primary_key: :id
  belongs_to :post, class_name: "Instagram::Post", foreign_key: :instagram_post_id, primary_key: :id
  belongs_to :account, class_name: "Instagram::Account", foreign_key: :instagram_account_id, primary_key: :id
  belongs_to :parent_comment, class_name: "Instagram::Comment", foreign_key: :instagram_comment_id, primary_key: :id, optional: true

  validates :text, presence: true
  validates :username, presence: true
end
