class Order < ApplicationRecord
  enum :status, { pending: "pending", paid: "paid", canceled: "canceled", refunded: "refunded" }, validate: true

  belongs_to :user
  belongs_to :group_deal
  has_many :payments, dependent: :destroy

  validates :total_cents, numericality: { only_integer: true, greater_than: 0 }
end
