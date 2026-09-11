# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Orders', type: :request do
  let!(:user) do
    User.create!(
      email: 'buyer@example.com',
      password: 'password',
      password_confirmation: 'password',
      name: '山田太郎'
    )
  end
  let!(:store) { Store.create!(name: '店舗', code: 'ORDERS-REQ-STORE') }
  let!(:product) { create_product!(store: store, name: 'りんご', code: 'ORDERS-REQ-APPLE') }

  before { sign_in user }

  describe 'GET /orders/new' do
    it 'カートが空のときは空のメッセージを表示する' do
      get new_cart_order_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('カートは空です')
    end

    it '明細があるとき、確認画面を表示する' do
      post cart_items_path, params: { cart_item: { product_id: product.id, quantity: 2 } }

      get new_cart_order_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('注文確認')
      expect(response.body).to include('2')
    end
  end

  describe 'POST /orders' do
    it 'カートが空のときはカートへ戻し、注文を作らない' do
      expect { post cart_orders_path }.not_to change(Order, :count)
      expect(response).to redirect_to(cart_path)
    end

    it 'カートに商品があるとき、注文を保存して完了画面へ進む' do
      post cart_items_path, params: { cart_item: { product_id: product.id, quantity: 2 } }

      order_attrs = {
        shipping_postal_code: '1000001',
        shipping_prefecture: '東京都',
        shipping_city: '千代田区',
        shipping_address_line: '1-1-1'
      }

      expect { post cart_orders_path, params: { order: order_attrs } }.to change(Order, :count).by(1)
                                                                                               .and change(OrderItem,
                                                                                                           :count).by(1)

      order = Order.last
      expect(order.payment_status).to eq('paid')
      expect(order.user).to eq(user)
      expect(order.order_items.first.quantity).to eq(2)
      expect(Cart.count).to eq(0)
      expect(response).to redirect_to(order_path(order.order_number))
    end
  end

  describe 'GET /orders' do
    it '自分の注文一覧を表示する' do
      order = user.orders.create!(status: 'new', payment_status: 'paid')
      get orders_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(order.order_number)
      expect(response.body).not_to include('詳細')
    end
  end

  describe 'GET /orders/:id' do
    it '他人の注文は参照できない' do
      other = User.create!(email: 'other@example.com', password: 'password', password_confirmation: 'password')
      other_order = other.orders.create!(status: 'new', payment_status: 'paid')

      get order_path(other_order.order_number)
      expect(response).to redirect_to(cart_path)
    end
  end
end
