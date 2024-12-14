class CreatePaymentIntentTable < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_intents do |t|
      t.references :invoice, null: false, foreign_key: true, index: :true
      t.float :amount, null: false
      t.integer :status, null: false
      t.string :decline_code
      t.string :error_message

      t.timestamps
    end
  end
end
