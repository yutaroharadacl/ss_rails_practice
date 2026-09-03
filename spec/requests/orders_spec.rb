# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  describe 'GET /orders/new' do
    it 'カートが空のときは空のメッセージを表示する' do
      get new_order_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('カートは空です')
    end

    it '明細があるとき、確認画面を表示する' do
      post cart_items_path, params: { cart_item: { product_id: 1, quantity: 2 } }

      get new_order_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('注文確認')
      expect(response.body).to include('2')
    end
  end

  describe 'POST /orders' do
    it 'カートが空のときはカートへ戻し、注文を作らない' do
      expect { post orders_path }.not_to change(Order, :count)
      expect(response).to redirect_to(cart_path)
    end

    it 'カートに商品があるとき、注文を保存して完了画面へ進む' do
      post cart_items_path, params: { cart_item: { product_id: 1, quantity: 2 } }

      expect { post orders_path }.to change(Order, :count).by(1)
        .and change(OrderItem, :count).by(1)

      order = Order.last
      expect(order.payment_status).to eq('paid')
      expect(order.order_items.first.quantity).to eq(2)
      expect(Cart.count).to eq(0)
      expect(response).to redirect_to(order_path(order))
    end
  end
end
