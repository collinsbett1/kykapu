class User < ApplicationRecord
  has_many :initiated_group_deals, class_name: "GroupDeal", foreign_key: :initiator_id, inverse_of: :initiator, dependent: :restrict_with_exception
  has_many :group_participants, dependent: :destroy
  has_many :joined_group_deals, through: :group_participants, source: :group_deal
  has_many :orders, dependent: :destroy

  validates :email, presence: true, uniqueness: true
end
