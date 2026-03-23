require "application_system_test_case"

class GroupBuyingFlowTest < ApplicationSystemTestCase
  test "user starts and another user joins a group deal" do
    initiator = User.create!(email: "system-init@example.com")
    joiner = User.create!(email: "system-joiner@example.com")
    product = Product.create!(
      title: "Smart Mug",
      description: "Temperature-controlled mug",
      solo_price_cents: 7000,
      group_price_cents: 5400,
      min_group_size: 2,
      group_window_minutes: 30,
      inventory_count: 8
    )

    visit product_path(product, as_user_id: initiator.id)
    click_button "Start a Group"
    assert_text "Group deal started."
    assert_text "Deal ##{GroupDeal.last.id}"
    assert_text "1 / 2"

    visit group_deal_path(GroupDeal.last, as_user_id: joiner.id)
    click_button "Join this group"
    assert_text "Joined the group deal."
    assert_text "SUCCESSFUL"
    assert_text "2 / 2"
  end
end
