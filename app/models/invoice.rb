class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :bulk_discounts, through: :invoice_items
  enum status: ["Cancelled", "Completed", "In Progress"]

  def self.incomplete_invoices
    where(status: "In Progress").order(:created_at)
  end

  def self.invoices_for(merchant)
    invoice_ids = merchant.invoice_items.pluck("invoice_id")
    Invoice.where(id: invoice_ids)
  end

  def customer_last
    customer.last_name
  end

  def customer_first
    customer.first_name
  end

  def total_revenue(merchant)
    items.where(merchant_id: merchant)
         .sum("invoice_items.quantity * invoice_items.unit_price")
  end

  def discounted_revenue(merchant)
    invoice_items.all
    invoice_items.joins(:item)
                 .left_outer_joins(:bulk_discount)
                 .where("items.merchant_id = #{merchant.id}")
                 .sum("invoice_items.quantity * invoice_items.unit_price * (100 - coalesce(bulk_discounts.discount, 0)) * 0.01")
  end

  def admin_total_revenue
    invoice_items.sum("quantity * unit_price")
  end

  def admin_discounted_revenue
    invoice_items.joins(:item)
                 .left_outer_joins(:bulk_discount)
                 .sum("invoice_items.quantity * invoice_items.unit_price * (100 - coalesce(bulk_discounts.discount, 0)) * 0.01")
  end
end


