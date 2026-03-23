module GroupDeals
  class Create
    Result = Struct.new(:group_deal, :errors, keyword_init: true) do
      def success?
        errors.blank?
      end
    end

    def self.call(product:, initiator:, now: Time.current)
      new(product:, initiator:, now:).call
    end

    def initialize(product:, initiator:, now:)
      @product = product
      @initiator = initiator
      @now = now
    end

    def call
      ActiveRecord::Base.transaction do
        product.lock!
        return failure("Product is inactive") unless product.active?
        return failure("Insufficient inventory") if product.inventory_count <= 0

        group_deal = GroupDeal.create!(
          product:,
          initiator:,
          target_size: product.min_group_size,
          expires_at: now + product.group_window_minutes.minutes,
          locked_price_cents: product.group_price_cents,
          status: :forming
        )

        GroupParticipant.create!(
          group_deal:,
          user: initiator,
          status: :committed,
          joined_at: now
        )

        product.update!(inventory_count: product.inventory_count - 1)

        if group_deal.group_participants.count >= group_deal.target_size
          group_deal.update!(status: :successful)
        end

        Result.new(group_deal:, errors: [])
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    rescue ActiveRecord::RecordNotUnique
      failure("Initiator already joined this group")
    end

    private

    attr_reader :product, :initiator, :now

    def failure(errors)
      normalized_errors = Array(errors)
      Result.new(group_deal: nil, errors: normalized_errors)
    end
  end
end
