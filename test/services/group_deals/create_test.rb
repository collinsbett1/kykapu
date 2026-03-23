require "test_helper"

class GroupDeals::CreateTest < ActiveSupport::TestCase
  test "creates group deal with initiator as first participant" do
    user = User.create!(email: "buyer1@example.com")
    product = Product.create!(
      title: "Wireless Earbuds",
      solo_price_cents: 2900,
      group_price_cents: 2400,
      min_group_size: 2,
      group_window_minutes: 30,
      inventory_count: 5
    )

    result = GroupDeals::Create.call(product:, initiator: user)

    assert result.success?
    group_deal = result.group_deal
    assert_equal "forming", group_deal.status
    assert_equal 1, group_deal.group_participants.count
    assert_equal user.id, group_deal.group_participants.first.user_id
    assert_equal 4, product.reload.inventory_count
  end

  test "fails when product has no inventory" do
    user = User.create!(email: "buyer2@example.com")
    product = Product.create!(
      title: "Bluetooth Speaker",
      solo_price_cents: 5000,
      group_price_cents: 4200,
      min_group_size: 3,
      group_window_minutes: 45,
      inventory_count: 0
    )

    result = GroupDeals::Create.call(product:, initiator: user)

    assert_not result.success?
    assert_includes result.errors, "Insufficient inventory"
  end
end
