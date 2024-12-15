class CreatePaymentIntentTable < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_intents do |t|
      t.float :amount, null: :false
      t.integer :subscription_id, null: :false

      t.timestamps
    end
  end
end
