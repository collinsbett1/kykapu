require "test_helper"

class GroupDealsFlowTest < ActionDispatch::IntegrationTest
  test "start and join a group deal through HTTP endpoints" do
    initiator = User.create!(email: "api-init@example.com")
    joiner = User.create!(email: "api-joiner@example.com")
    product = Product.create!(
      title: "Rice Cooker",
      solo_price_cents: 9900,
      group_price_cents: 8500,
      min_group_size: 2,
      group_window_minutes: 30,
      inventory_count: 4
    )

    post group_deals_path, params: { product_id: product.id, initiator_id: initiator.id }, as: :json
    assert_response :created

    created_body = JSON.parse(response.body)
    group_deal_id = created_body.fetch("id")
    assert_equal "forming", created_body.fetch("status")

    post join_group_deal_path(group_deal_id), params: { user_id: joiner.id }, as: :json
    assert_response :ok

    joined_body = JSON.parse(response.body)
    assert_equal "successful", joined_body.fetch("status")
    assert_equal 2, joined_body.fetch("participant_count")
  end
end
