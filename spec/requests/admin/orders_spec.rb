# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Orders', type: :request do
  let!(:order) { Order.create(status: 'new') }
  let!(:store) { Store.create!(name: '店舗', code: 'STORE') }
  let!(:product) { create_product!(store: store, name: 'りんご', code: 'APPLE', sku_attributes: { price: 1000 }) }

  describe 'GET /admin/orders' do
    it '一覧が正常に取得できる' do
      get admin_orders_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('ID')
      expect(response.body).to include('1')
      expect(response.body).to include('名前')
      expect(response.body).to include('—')
      expect(response.body).to include('対応状況')
      expect(response.body).to include('新規')
    end

    context '検索条件を指定した場合' do
      let!(:completed_order) { Order.create(status: 'complete') }

      it 'IDで絞り込める' do
        get admin_orders_path, params: { q: { id_eq: order.id } }
        expect(response.body).to include(order.order_number)
        expect(response.body).not_to include(completed_order.order_number)
      end

      it '受注番号の部分一致で絞り込める' do
        get admin_orders_path, params: { q: { order_number_cont: order.order_number[0, 5] } }
        expect(response.body).to include(order.order_number)
        expect(response.body).not_to include(completed_order.order_number)
      end

      it '対応状況で絞り込める' do
        get admin_orders_path, params: { q: { status_eq: 'complete' } }
        expect(response.body).to include(completed_order.order_number)
        expect(response.body).not_to include(order.order_number)
      end

      it '該当する受注がない場合はその旨が表示される' do
        get admin_orders_path, params: { q: { id_eq: 0 } }
        expect(response.body).to include('該当する受注が見つかりませんでした。')
      end

      it '検索条件が空の場合は全件表示される' do
        get admin_orders_path, params: { q: { id_eq: '', order_number_cont: '', status_eq: '' } }
        expect(response.body).to include(order.order_number)
        expect(response.body).to include(completed_order.order_number)
      end
    end
  end

  describe 'GET /admin/orders/:id' do
    let!(:order_item) { order.order_items.create!(product_id: product.id, quantity: 2, price: 1000) }
    it '詳細が正常に取得できる' do
      get admin_order_path(order)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('基本情報')
      expect(response.body).to include('受注商品管理')
      expect(response.body).to include('ID')
      expect(response.body).to include('1')
      expect(response.body).to include('出荷準備中')
      expect(response.body).to include('対応状況')
      expect(response.body).to include('名前')
      expect(response.body).to include('単価')
      expect(response.body).to include('value="1000"')
      expect(response.body).to include('個数')
      expect(response.body).to include('value="2"')
      expect(response.body).to include('りんご')
      expect(response.body).to include('APPLE')
    end

    it '商品が削除されている場合でもエラーにならず「削除された商品」と表示される' do
      product.destroy!
      get admin_order_path(order)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('削除された商品')
    end
  end

  describe 'PATCH /admin/orders/:id' do
    let!(:order_item) { order.order_items.create!(product_id: product.id, quantity: 2, price: 1000) }
    context 'statusがnewの場合' do
      it 'statusがcompleteに更新される' do
        patch admin_order_path(order), params: { order: { status: 'complete' } }
        expect(order.reload.status).to eq('complete')
      end

      it 'order_itemの変更が可能' do
        patch admin_order_path(order), params: { order: { order_items_attributes: {
          '0' => { id: order_item.id, quantity: 3, price: 2000 }
        } } }

        expect(order_item.reload.price).to eq(2000)
        expect(order_item.reload.quantity).to eq(3)
      end

      it 'order_itemを削除できる' do
        expect do
          patch admin_order_path(order), params: { order: { order_items_attributes: {
            '0' => { id: order_item.id, _destroy: '1' }
          } } }
        end.to change(OrderItem, :count).by(-1)
      end
    end

    context 'statusがcompleteの場合' do
      let!(:order) { Order.create(status: 'complete') }
      it 'statusは変更されない' do
        patch admin_order_path(order), params: { order: { status: 'new' } }
        expect(order.reload.status).to eq('complete')
      end

      it 'order_itemの変更は不可' do
        patch admin_order_path(order), params: { order: { order_items_attributes: {
          '0' => { id: order_item.id, quantity: 3, price: 2000 }
        } } }

        order_item.reload
        expect(order_item.quantity).not_to eq(3)
        expect(order_item.price).not_to eq(2000)
      end

      it 'order_itemを削除できない' do
        expect do
          patch admin_order_path(order), params: { order: { order_items_attributes: {
            '0' => { id: order_item.id, _destroy: '1' }
          } } }
        end.to change(OrderItem, :count).by(0)
      end
    end
  end
end
