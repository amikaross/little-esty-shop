class InvoicesController < ApplicationController  
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @invoices = Invoice.invoices_for(@merchant)
  end

  def show
    @invoice = Invoice.find(params[:id])
    @merchant = Merchant.find(params[:merchant_id])
    @items = @invoice.invoice_items.joins(:item).where("items.merchant_id = #{@merchant.id}")
  end
end
