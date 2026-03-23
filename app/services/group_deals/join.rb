module GroupDeals
  class Join
    Result = Struct.new(:group_deal, :group_participant, :errors, keyword_init: true) do
      def success?
        errors.blank?
      end
    end

    def self.call(group_deal:, user:, now: Time.current)
      new(group_deal:, user:, now:).call
    end

    def initialize(group_deal:, user:, now:)
      @group_deal = group_deal
      @user = user
      @now = now
    end

    def call
      ActiveRecord::Base.transaction do
        group_deal.lock!
        product = group_deal.product
        product.lock!

        return failure("Group is not open for joining") unless group_deal.forming?
        return failure("Group has expired") if group_deal.expires_at <= now
        return failure("Insufficient inventory") if product.inventory_count <= 0

        participant = GroupParticipant.create!(
          group_deal:,
          user:,
          status: :committed,
          joined_at: now
        )

        product.update!(inventory_count: product.inventory_count - 1)

        if group_deal.group_participants.count >= group_deal.target_size
          group_deal.update!(status: :successful)
        end

        Result.new(group_deal:, group_participant: participant, errors: [])
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    rescue ActiveRecord::RecordNotUnique
      failure("User already joined this group")
    end

    private

    attr_reader :group_deal, :user, :now

    def failure(errors)
      normalized_errors = Array(errors)
      Result.new(group_deal:, group_participant: nil, errors: normalized_errors)
    end
  end
end
