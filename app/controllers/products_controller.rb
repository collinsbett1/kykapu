class ProductsController < ApplicationController
  def index
    @pagy, @products = pagy(Product.where(active: true).order(created_at: :desc), limit: 50)

    respond_to do |format|
      format.html
      format.json { render json: { products: @products.map { |product| product_payload(product) }, meta: pagy_metadata(@pagy) } }
    end
  end

  def show
    @product = Product.find(params[:id])
    @active_group_deals = @product.group_deals.active.includes(:group_participants).order(created_at: :desc)

    respond_to do |format|
      format.html
      format.json { render json: product_payload(@product, include_active_groups: true) }
    end
  end

  private

  def product_payload(product, include_active_groups: false)
    payload = {
      id: product.id,
      title: product.title,
      description: product.description,
      solo_price_cents: product.solo_price_cents,
      group_price_cents: product.group_price_cents,
      min_group_size: product.min_group_size,
      group_window_minutes: product.group_window_minutes,
      inventory_count: product.inventory_count
    }

    return payload unless include_active_groups

    payload[:active_group_deals] = product.group_deals.active.map do |group_deal|
      group_deal_payload(group_deal)
    end
    payload
  end

  def group_deal_payload(group_deal)
    {
      id: group_deal.id,
      status: group_deal.status,
      target_size: group_deal.target_size,
      participant_count: group_deal.group_participants.size,
      expires_at: group_deal.expires_at
    }
  end
end
