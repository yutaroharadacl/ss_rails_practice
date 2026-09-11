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
  let!(:product) do
    create_product!(store: store, name: 'りんご', code: 'ORDERS-REQ-APPLE', sku_attributes: { stock_quantity: 10 })
  end
  let!(:other_product) do
    create_product!(store: store, name: 'みかん', code: 'ORDERS-REQ-ORANGE', sku_attributes: { stock_quantity: 5 })
  end

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
    let(:order_attrs) do
      {
        shipping_postal_code: '1000001',
        shipping_prefecture: '東京都',
        shipping_city: '千代田区',
        shipping_address_line: '1-1-1'
      }
    end

    it 'カートが空のときはカートへ戻し、注文を作らない' do
      expect { post cart_orders_path }.not_to change(Order, :count)
      expect(response).to redirect_to(cart_path)
      expect(flash[:alert]).to eq(I18n.t('flash.orders.error.empty_cart'))
    end

    it 'カートに商品があるとき、注文を保存して完了画面へ進む' do
      post cart_items_path, params: { cart_item: { product_id: product.id, quantity: 2 } }

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

    it '注文が成立したとき、カートにある全商品の在庫が数量ぶん減る' do
      post cart_items_path, params: { cart_item: { product_id: product.id, quantity: 2 } }
      post cart_items_path, params: { cart_item: { product_id: other_product.id, quantity: 3 } }

      post cart_orders_path, params: { order: order_attrs }

      expect(product.sku.reload.stock_quantity).to eq(8)
      expect(other_product.sku.reload.stock_quantity).to eq(2)
    end

    it '在庫が不足しているときはカートへ戻し、注文を作らない' do
      post cart_items_path, params: { cart_item: { product_id: product.id, quantity: 2 } }
      # カートに入れた後に他の注文で在庫が減ったケースを再現する
      product.sku.update!(stock_quantity: 1)

      expect { post cart_orders_path, params: { order: order_attrs } }.not_to change(Order, :count)
      expect(response).to redirect_to(cart_path)
      expect(flash[:alert]).to eq(I18n.t('flash.orders.error.out_of_stock'))
      expect(product.sku.reload.stock_quantity).to eq(1)
    end

    it 'カート内の1商品だけ在庫が不足している場合も、どの在庫も減らさない' do
      post cart_items_path, params: { cart_item: { product_id: product.id, quantity: 2 } }
      post cart_items_path, params: { cart_item: { product_id: other_product.id, quantity: 3 } }
      other_product.sku.update!(stock_quantity: 1)

      expect { post cart_orders_path, params: { order: order_attrs } }.not_to change(Order, :count)
      expect(response).to redirect_to(cart_path)
      expect(flash[:alert]).to eq(I18n.t('flash.orders.error.out_of_stock'))
      expect(product.sku.reload.stock_quantity).to eq(10)
      expect(other_product.sku.reload.stock_quantity).to eq(1)
    end

    it '在庫チェック通過後に在庫が減っていた場合もカートへ戻し、注文を作らない' do
      post cart_items_path, params: { cart_item: { product_id: product.id, quantity: 2 } }
      # before_action の在庫チェックを通過した後に、他の注文で在庫が減ったケースを再現する
      allow_any_instance_of(Sku).to receive(:decrement_stock!).and_raise(Sku::InsufficientStockError)

      expect { post cart_orders_path, params: { order: order_attrs } }.not_to change(Order, :count)
      expect(response).to redirect_to(cart_path)
      expect(flash[:alert]).to eq(I18n.t('flash.orders.error.out_of_stock'))
      expect(product.sku.reload.stock_quantity).to eq(10)
    end

    it '在庫はSKUのid順に減算する（デッドロック防止）' do
      # カートへの投入順とSKUのid順が逆になるように入れる
      post cart_items_path, params: { cart_item: { product_id: other_product.id, quantity: 1 } }
      post cart_items_path, params: { cart_item: { product_id: product.id, quantity: 1 } }
      decremented_ids = []
      allow_any_instance_of(Sku).to receive(:decrement_stock!) { |sku, _quantity| decremented_ids << sku.id }

      post cart_orders_path, params: { order: order_attrs }

      expect(decremented_ids).to eq([product.sku.id, other_product.sku.id])
    end

    it '注文の保存に失敗した場合は在庫も元に戻る' do
      post cart_items_path, params: { cart_item: { product_id: product.id, quantity: 2 } }
      # 在庫を減らした後の処理が失敗したとき、トランザクションで巻き戻ることを確認する
      allow(Order).to receive(:create!).and_raise(ActiveRecord::RecordInvalid.new(Order.new))

      expect { post cart_orders_path, params: { order: order_attrs } }.not_to change(Order, :count)
      expect(response).to redirect_to(cart_path)
      expect(product.sku.reload.stock_quantity).to eq(10)
    end
  end

  describe 'GET /orders/new' do
    it '在庫が不足しているときはカートへ戻す' do
      post cart_items_path, params: { cart_item: { product_id: product.id, quantity: 2 } }
      product.sku.update!(stock_quantity: 1)

      get new_cart_order_path

      expect(response).to redirect_to(cart_path)
      expect(flash[:alert]).to eq(I18n.t('flash.orders.error.out_of_stock'))
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
