class CreateChargeTable < ActiveRecord::Migration[8.0]
  def change
    create_table :charges do |t|
      t.references :payment_intent, null: false, foreign_key: true, index: :true
      t.float :amount, null: false
      t.integer :status, null: false
      t.string :decline_code
      t.string :error_message

      t.timestamps
    end
  end
end
