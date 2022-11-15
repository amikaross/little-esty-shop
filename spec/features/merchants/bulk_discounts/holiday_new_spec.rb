require "rails_helper"

RSpec.describe "New Merchant Bulk Discount page" do 
  before(:each) do 
    @merchant = Merchant.create!(name: "Savory Spice")
    @discount_1 = @merchant.bulk_discounts.create!(discount: 10, threshold: 5, name: "Discount 1")
    @discount_2 = @merchant.bulk_discounts.create!(discount: 20, threshold: 10, name: "Discount 2")

    @response_body = File.open('./spec/fixtures/response.json')
    stub_request(:get, "https://date.nager.at/api/v3/NextPublicHolidays/US").
         with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: @response_body, headers: {})
  end

  describe "When I click the create discount button next to a holiday" do 
    it "i'm taken to a form to create a new discount with fields infilled, clicking submit redirects you to the index where the discount has been added" do 
      visit merchant_bulk_discounts_path(@merchant) 

      expect(page).to_not have_content("Thanksgiving Day Discount")
      expect(page).to_not have_content("Percentage Discount: 30")
      expect(page).to_not have_content("Quantity Threshold: 2")

      within "#holiday-1" do 
        click_button("Create Discount")
      end

      expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant))
      expect(page).to have_field(:name, with: "Thanksgiving Day Discount")
      expect(page).to have_field(:discount, with: "30")
      expect(page).to have_field(:threshold, with: "2")

      click_button("Submit")

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant))
      expect(page).to have_content("Thanksgiving Day Discount")
      expect(page).to have_content("Percentage Discount: 30")
      expect(page).to have_content("Quantity Threshold: 2")
    end
  end
end