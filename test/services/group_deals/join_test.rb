require "test_helper"

class GroupDeals::JoinTest < ActiveSupport::TestCase
  test "joins a forming group and marks it successful when target size is reached" do
    initiator = User.create!(email: "init@example.com")
    joiner = User.create!(email: "joiner@example.com")
    product = Product.create!(
      title: "Kitchen Scale",
      solo_price_cents: 3200,
      group_price_cents: 2600,
      min_group_size: 2,
      group_window_minutes: 60,
      inventory_count: 5
    )
    group_deal = GroupDeals::Create.call(product:, initiator:).group_deal

    result = GroupDeals::Join.call(group_deal:, user: joiner)

    assert result.success?
    assert_equal "successful", group_deal.reload.status
    assert_equal 2, group_deal.group_participants.count
    assert_equal 3, product.reload.inventory_count
  end

  test "fails when same user tries to join twice" do
    initiator = User.create!(email: "init2@example.com")
    joiner = User.create!(email: "joiner2@example.com")
    product = Product.create!(
      title: "Portable Fan",
      solo_price_cents: 1800,
      group_price_cents: 1400,
      min_group_size: 3,
      group_window_minutes: 60,
      inventory_count: 5
    )
    group_deal = GroupDeals::Create.call(product:, initiator:).group_deal
    GroupDeals::Join.call(group_deal:, user: joiner)

    result = GroupDeals::Join.call(group_deal:, user: joiner)

    assert_not result.success?
    assert_includes result.errors.join(" "), "already"
  end

  test "fails when group is expired" do
    initiator = User.create!(email: "init3@example.com")
    joiner = User.create!(email: "joiner3@example.com")
    product = Product.create!(
      title: "Water Bottle",
      solo_price_cents: 1500,
      group_price_cents: 1200,
      min_group_size: 2,
      group_window_minutes: 1,
      inventory_count: 5
    )
    group_deal = GroupDeals::Create.call(product:, initiator:).group_deal
    group_deal.update!(expires_at: 1.minute.ago)

    result = GroupDeals::Join.call(group_deal:, user: joiner)

    assert_not result.success?
    assert_includes result.errors, "Group has expired"
  end
end
