require "rails_helper"

RSpec.describe BulkDiscount, type: :model do 
  describe "Relationships" do 
    it { should belong_to :merchant }
  end

  describe "Validations" do 
    it { should validate_numericality_of(:discount).is_greater_than(0).is_less_than(100).only_integer }
    it { should validate_numericality_of(:threshold).is_greater_than(0).only_integer }
    it { should validate_presence_of :discount }
    it { should validate_presence_of :threshold }
  end

  describe "instance methods" do 
    describe "#can_be_applied" do 
      it "adds the appropriate error if the proposed discount will never be applied" do 
        merchant = Merchant.create!(name: "I'm a merchant")
        bulk_discount_1 = BulkDiscount.create!(discount: 20, threshold: 10, merchant: merchant)
        bulk_discount_2 = BulkDiscount.new(discount: 15, threshold: 15, merchant: merchant)

        expect(bulk_discount_2.valid?).to eq(false)
        expect(bulk_discount_2.errors.messages).to eq({:discount=>["is less than the current highest discount, but with a greater threshold, and will never be applied"]})
      end
    end
  end
end