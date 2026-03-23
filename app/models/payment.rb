class Payment < ApplicationRecord
  enum :status, { pending: "pending", authorized: "authorized", captured: "captured", failed: "failed", refunded: "refunded" }, validate: true

  belongs_to :order

  validates :provider, :intent_id, presence: true
  validates :intent_id, uniqueness: { scope: :provider }
end
