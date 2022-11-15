require "rails_helper"

RSpec.describe "Merchant Bulk Discounts Index page" do 
  before(:each) do 
    @merchant = Merchant.create!(name: "Savory Spice")
    @discount_1 = @merchant.bulk_discounts.create!(discount: 10, threshold: 5)
    @discount_2 = @merchant.bulk_discounts.create!(discount: 20, threshold: 10)
    @discount_3 = @merchant.bulk_discounts.create!(discount: 30, threshold: 15)
  end

  describe "As a merchant, when I visit my merchant dashboard" do 
    it "has a link to view all of my discounts, which takes you to the discounts index" do 
      visit merchant_dashboard_index_path(@merchant)

      expect(page).to have_link("My Discounts")

      click_link("My Discounts")

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant))
    end
  end

  describe "As a merchant, when I visit my merchant discounts index page" do 
    it "displays all of my bulk discounts including discount percentage and quantity thresholds" do 
      visit merchant_bulk_discounts_path(@merchant)

      within "#bulk-discount-#{@discount_1.id}" do 
        expect(page).to have_content("Bulk Discount ##{@discount_1.id}")
        expect(page).to have_content("Quantity Threshold: 5 items")
        expect(page).to have_content("Percentage Discount: 10%")
      end

      within "#bulk-discount-#{@discount_2.id}" do 
        expect(page).to have_content("Bulk Discount ##{@discount_2.id}")
        expect(page).to have_content("Quantity Threshold: 10 items")
        expect(page).to have_content("Percentage Discount: 20%")
      end

      within "#bulk-discount-#{@discount_3.id}" do 
        expect(page).to have_content("Bulk Discount ##{@discount_3.id}")
        expect(page).to have_content("Quantity Threshold: 15 items")
        expect(page).to have_content("Percentage Discount: 30%")
      end
    end

    it "each bulk discount listed includes a link to its show page" do 
      visit merchant_bulk_discounts_path(@merchant)

      expect(page).to have_link("Bulk Discount ##{@discount_1.id}", href: merchant_bulk_discount_path(@merchant, @discount_1))
      expect(page).to have_link("Bulk Discount ##{@discount_2.id}", href: merchant_bulk_discount_path(@merchant, @discount_2))
      expect(page).to have_link("Bulk Discount ##{@discount_3.id}", href: merchant_bulk_discount_path(@merchant, @discount_3))
    end

    it "has a link to create a new bulk discount, which takes me to a page to create a discount" do 
      visit merchant_bulk_discounts_path(@merchant)
      expect(page).to have_link("Create New Bulk Discount", href: new_merchant_bulk_discount_path(@merchant))
    end

    it "has a button to Delete Discount for each of the listed bulk discounts, when clicked i'm redirected back to index where discount has been removed" do
      visit merchant_bulk_discounts_path(@merchant)

      within "#bulk-discount-#{@discount_1.id}" do 
        expect(page).to have_button("Delete Discount")
      end

      within "#bulk-discount-#{@discount_2.id}" do 
        expect(page).to have_button("Delete Discount")
      end

      within "#bulk-discount-#{@discount_3.id}" do 
        expect(page).to have_button("Delete Discount")
        expect(page).to have_content("Quantity Threshold: 15 items")
        expect(page).to have_content("Percentage Discount: 30%")
        click_button("Delete Discount")
      end

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant))
      expect(page).to_not have_content("Quantity Threshold: 15 items")
      expect(page).to_not have_content("Percentage Discount: 30%")
    end

    it "can delete a bulk discount even if it's already been 'applied' to an invoice_item" do 
      cumin = @merchant.items.create!(name: "Cumin", description: "Some Cumin", unit_price: 1)
      customer = Customer.create!(first_name: "Lee", last_name: "Saville")
      invoice = customer.invoices.create!(status: 1)
      InvoiceItem.create!(invoice: invoice, item: cumin, unit_price: 1, quantity: 30)
      
      visit merchant_bulk_discounts_path(@merchant)

      within "#bulk-discount-#{@discount_3.id}" do
        click_button("Delete Discount")
      end

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant))
      expect(page).to_not have_content("Quantity Threshold: 15 items")
      expect(page).to_not have_content("Percentage Discount: 30%")
    end

    it "has a section for Upcoming Holidays which displays the next 3 US Holidays" do 
      visit merchant_bulk_discounts_path(@merchant)

      expect(page).to have_content("Upcoming Holidays:")
      expect(page).to have_content("Thanksgiving Day - 2022-11-24")
      expect(page).to have_content("Christmas Day - 2022-12-26")
      expect(page).to have_content("New Year's Day - 2023-01-02")
    end
  end
end