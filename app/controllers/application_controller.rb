require "securerandom"

class ApplicationController < ActionController::Base
  include Pagy::Backend
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :persist_actor_override

  helper_method :current_user, :available_users

  private

  def current_user
    @current_user ||= begin
      selected = User.find_by(id: session[:actor_user_id])
      selected || User.order(:id).first || User.create!(email: "shopper-#{SecureRandom.hex(4)}@example.com", name: "Guest Shopper")
    end
  end

  def available_users
    User.order(:id).limit(10)
  end

  def persist_actor_override
    actor_id = params[:as_user_id]
    return if actor_id.blank?

    user = User.find_by(id: actor_id)
    session[:actor_user_id] = user.id if user
  end
end
