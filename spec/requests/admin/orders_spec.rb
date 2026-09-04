# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Orders', type: :request do
  let!(:order) { Order.create(customer_name: '山田太郎', customer_email: 'a@example.com', status: 'new') }

  describe 'GET /admin/orders' do
    it '一覧が正常に取得できる' do
      get admin_orders_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include('ID')
      expect(response.body).to include('1')
      expect(response.body).to include('名前')
      expect(response.body).to include('山田太郎')
      expect(response.body).to include('対応状況')
      expect(response.body).to include('新規')
    end
  end

  describe 'GET /admin/orders/:id' do
    let!(:order_item) { order.order_items.create!(product_id: 1, quantity: 2, price: 1000) }
    it '詳細が正常に取得できる' do
      get admin_order_path(order)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('基本情報')
      expect(response.body).to include('受注商品管理')
      expect(response.body).to include('ID')
      expect(response.body).to include('1')
      expect(response.body).to include('完了にする')
      expect(response.body).to include('名前')
      expect(response.body).to include('単価')
      expect(response.body).to include('value="1000"')
      expect(response.body).to include('個数')
      expect(response.body).to include('value="2"')
    end
  end

  describe 'PATCH /admin/orders/:id' do
    let!(:order_item) { order.order_items.create!(product_id: 1, quantity: 2, price: 1000) }
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
        expect {
          patch admin_order_path(order), params: { order: { order_items_attributes: {
            '0' => { id: order_item.id, _destroy: '1'}
          }}}
        }.to change(OrderItem, :count).by(-1)
      end
    end

    context 'statusがcompleteの場合' do
      let!(:order) { Order.create(customer_name: '山田太郎', customer_email: 'a@example.com', status: 'complete') }
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
        expect {
          patch admin_order_path(order), params: { order: { order_items_attributes: {
            '0' => { id: order_item.id, _destroy: '1'}
          }}}
        }.to change(OrderItem, :count).by(0)
      end
    end
  end
end
