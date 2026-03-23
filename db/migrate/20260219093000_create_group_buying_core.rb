class CreateGroupBuyingCore < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name

      t.timestamps
    end

    add_index :users, :email, unique: true

    create_table :products do |t|
      t.string :title, null: false
      t.text :description
      t.integer :solo_price_cents, null: false
      t.integer :group_price_cents, null: false
      t.integer :min_group_size, null: false, default: 2
      t.integer :group_window_minutes, null: false, default: 60
      t.integer :inventory_count, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    create_table :group_deals do |t|
      t.references :product, null: false, foreign_key: true
      t.references :initiator, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "forming"
      t.integer :target_size, null: false
      t.datetime :expires_at, null: false
      t.integer :locked_price_cents, null: false

      t.timestamps
    end

    add_index :group_deals, :status
    add_index :group_deals, :expires_at

    create_table :group_participants do |t|
      t.references :group_deal, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "committed"
      t.datetime :joined_at, null: false

      t.timestamps
    end

    add_index :group_participants, [ :group_deal_id, :user_id ], unique: true
    add_index :group_participants, :status

    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group_deal, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.integer :total_cents, null: false

      t.timestamps
    end

    add_index :orders, :status

    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :intent_id, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :authorized_at
      t.datetime :captured_at
      t.datetime :refunded_at

      t.timestamps
    end

    add_index :payments, [ :provider, :intent_id ], unique: true
    add_index :payments, :status
  end
end
