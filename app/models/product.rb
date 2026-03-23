class Product < ApplicationRecord
  has_many :group_deals, dependent: :restrict_with_exception

  validates :title, presence: true
  validates :solo_price_cents, :group_price_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :min_group_size, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :group_window_minutes, numericality: { only_integer: true, greater_than: 0 }
  validates :inventory_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :group_price_must_not_exceed_solo_price

  private

  def group_price_must_not_exceed_solo_price
    return if group_price_cents.blank? || solo_price_cents.blank?
    return if group_price_cents <= solo_price_cents

    errors.add(:group_price_cents, "must be less than or equal to solo price")
  end
end
