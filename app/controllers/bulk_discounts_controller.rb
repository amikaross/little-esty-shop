class BulkDiscountsController < ApplicationController 
  before_action :get_holidays, only: [:index]
  after_action :update_item_discounts, only: [:create, :destroy, :edit]
  
  def index 
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show 
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
    if params[:holiday]
      @holiday = params[:holiday]
      render :holiday_new
    end
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    discount = merchant.bulk_discounts.create(app_params)
    if discount.valid? 
      redirect_to merchant_bulk_discounts_path(merchant)
    else
      flash[:alert] = "Error: #{error_message(discount.errors)}"
      redirect_to new_merchant_bulk_discount_path(merchant)
    end
  end

  def destroy 
    merchant = Merchant.find(params[:merchant_id])
    discount = BulkDiscount.find(params[:id])
    invoice_items = InvoiceItem.where(bulk_discount: discount)

    invoice_items.update_all(bulk_discount_id: nil) unless invoice_items.empty?
    discount.destroy

    redirect_to merchant_bulk_discounts_path(merchant)
  end

  def edit 
    @merchant = Merchant.find(params[:merchant_id])
    @discount = BulkDiscount.find(params[:id])
  end

  def update 
    merchant = Merchant.find(params[:merchant_id])
    discount = BulkDiscount.find(params[:id])
    discount.update(app_params)
    if discount.valid? 
      redirect_to merchant_bulk_discount_path(merchant, discount)
    else 
      flash[:alert] = "Error: #{error_message(discount.errors)}"
      redirect_to edit_merchant_bulk_discount_path(merchant, discount)
    end
  end

  private
  def app_params
    params.permit(:merchant_id, :discount, :threshold, :name)
  end

  def get_holidays
    @holidays = HolidaySearch.new.holidays
  end

  def update_item_discounts 
    merchant = Merchant.find(params[:merchant_id])
    invoice_items = InvoiceItem.joins(:item).where(items: {merchant_id: merchant.id})
    invoice_items.each { |item| item.add_discount }
  end
end