class CreateInvoiceTable < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.float :amount, null: :false
      t.integer :subscription_id, null: :false

      t.timestamps
    end
  end
end
