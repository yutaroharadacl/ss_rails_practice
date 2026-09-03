require 'rails_helper'

RSpec.describe "Admin::OrderItems", type: :request do
  describe "GET /update" do
    it "returns http success" do
      get "/admin/order_items/update"
      expect(response).to have_http_status(:success)
    end
  end

end
