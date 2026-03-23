class GroupParticipant < ApplicationRecord
  enum :status, { committed: "committed", canceled: "canceled" }, prefix: true, validate: true

  belongs_to :group_deal
  belongs_to :user

  validates :joined_at, presence: true
  validates :user_id, uniqueness: { scope: :group_deal_id }

  after_commit :broadcast_group_deal_streams, on: [ :create, :update, :destroy ]

  private

  def broadcast_group_deal_streams
    deal = group_deal
    deal.broadcast_summary_stream
    deal.broadcast_replace_to(
      [ deal, :participants ],
      target: ActionView::RecordIdentifier.dom_id(deal, :participants),
      partial: "group_deals/participants",
      locals: { group_deal: deal }
    )
    deal.broadcast_to_product_stream
  end
end
