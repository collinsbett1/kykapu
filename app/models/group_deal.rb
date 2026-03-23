class GroupDeal < ApplicationRecord
  enum :status, { forming: "forming", successful: "successful", failed: "failed", expired: "expired" }, validate: true

  belongs_to :product
  belongs_to :initiator, class_name: "User", inverse_of: :initiated_group_deals
  has_many :group_participants, dependent: :destroy
  has_many :participants, through: :group_participants, source: :user
  has_many :orders, dependent: :restrict_with_exception

  validates :target_size, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :locked_price_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :expires_at, presence: true

  scope :active, -> { where(status: :forming).where("expires_at > ?", Time.current) }

  after_create_commit :broadcast_to_product_stream
  after_update_commit :broadcast_to_product_stream
  after_update_commit :broadcast_summary_stream

  def broadcast_to_product_stream
    stream = [ product, :group_deals ]
    target = ActionView::RecordIdentifier.dom_id(self, :card)

    if previous_changes.key?("id")
      broadcast_prepend_to(
        stream,
        target: "product_#{product_id}_group_deals",
        partial: "group_deals/card",
        locals: { group_deal: self }
      )
    else
      broadcast_replace_to(
        stream,
        target:,
        partial: "group_deals/card",
        locals: { group_deal: self }
      )
    end
  end

  def broadcast_summary_stream
    broadcast_replace_to(
      [ self, :summary ],
      target: ActionView::RecordIdentifier.dom_id(self, :summary),
      partial: "group_deals/summary",
      locals: { group_deal: self }
    )
  end
end
