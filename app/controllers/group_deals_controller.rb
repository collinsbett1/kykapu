class GroupDealsController < ApplicationController
  skip_forgery_protection

  def create
    product = Product.find(params[:product_id])
    initiator = params[:initiator_id].present? ? User.find(params[:initiator_id]) : current_user

    result = GroupDeals::Create.call(product:, initiator:)
    respond_to do |format|
      if result.success?
        format.html do
          redirect_to group_deal_path(result.group_deal, as_user_id: current_user.id), notice: "Group deal started."
        end
        format.json { render json: group_deal_payload(result.group_deal), status: :created }
      else
        format.html do
          redirect_back fallback_location: product_path(product, as_user_id: current_user.id), alert: result.errors.to_sentence
        end
        format.json { render json: { errors: result.errors }, status: :unprocessable_entity }
      end
    end
  end

  def show
    @group_deal = GroupDeal.includes(:product, group_participants: :user).find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: group_deal_payload(@group_deal, include_participants: true) }
    end
  end

  def join
    group_deal = GroupDeal.find(params[:id])
    user = params[:user_id].present? ? User.find(params[:user_id]) : current_user

    result = GroupDeals::Join.call(group_deal:, user:)
    respond_to do |format|
      if result.success?
        format.html do
          redirect_to group_deal_path(result.group_deal, as_user_id: current_user.id), notice: "Joined the group deal."
        end
        format.json { render json: group_deal_payload(result.group_deal, include_participants: true), status: :ok }
      else
        format.html do
          redirect_to group_deal_path(group_deal, as_user_id: current_user.id), alert: result.errors.to_sentence
        end
        format.json { render json: { errors: result.errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def group_deal_payload(group_deal, include_participants: false)
    payload = {
      id: group_deal.id,
      product_id: group_deal.product_id,
      initiator_id: group_deal.initiator_id,
      status: group_deal.status,
      target_size: group_deal.target_size,
      locked_price_cents: group_deal.locked_price_cents,
      expires_at: group_deal.expires_at,
      participant_count: group_deal.group_participants.count
    }

    return payload unless include_participants

    payload[:participants] = group_deal.group_participants.includes(:user).order(:joined_at).map do |participant|
      {
        user_id: participant.user_id,
        email: participant.user.email,
        status: participant.status,
        joined_at: participant.joined_at
      }
    end
    payload
  end
end
