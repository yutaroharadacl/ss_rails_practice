# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CartItems', type: :request do
  describe 'POST /cart_items' do
    it '初めて追加すると、指定した数量でCartItemが作成される' do
      expect do
        post cart_items_path, params: { cart_item: { product_id: 1, quantity: 2 } }
      end.to change(CartItem, :count).by(1)

      expect(CartItem.last.quantity).to eq(2)
    end

    it 'すでに存在する商品の場合、指定した数量でCartItemの数量が増加する' do
      post cart_items_path, params: { cart_item: { product_id: 1, quantity: 2 } }
      post cart_items_path, params: { cart_item: { product_id: 1, quantity: 3 } }

      expect(CartItem.count).to eq(1)
      expect(CartItem.last.quantity).to eq(5)
    end

    it '保存に成功したとき、cart_pathにリダイレクトする' do
      post cart_items_path, params: { cart_item: { product_id: 1, quantity: 2 } }
      expect(response).to redirect_to(cart_path)
    end

    it '保存に失敗したとき、cart_pathにリダイレクトする' do
      expect do
        post cart_items_path, params: { cart_item: { product_id: 1, quantity: 0 } }
      end.not_to change(CartItem, :count)
      expect(response).to redirect_to(cart_path)
    end
  end

  describe 'PATCH /cart_items/:id' do
    it '数量の変更ができること' do
      post cart_items_path, params: { cart_item: { product_id: 1, quantity: 2 } }
      item = CartItem.last

      patch cart_item_path(item), params: { cart_item: { quantity: 3 } }
      expect(item.reload.quantity).to eq(3)
    end

    it '0以下の値を指定したとき、エラーになること' do
      post cart_items_path, params: { cart_item: { product_id: 1, quantity: 2 } }
      item = CartItem.last

      patch cart_item_path(item), params: { cart_item: { quantity: 0 } }
      expect(response).to redirect_to(cart_path)
      expect(item.reload.quantity).to eq(2)
    end

    it '他セッションの明細は変更できないこと' do
      post cart_items_path, params: { cart_item: { product_id: 1, quantity: 2 } }
      item = CartItem.last

      reset! # セッションをリセット

      patch cart_item_path(item), params: { cart_item: { quantity: 3 } }
      expect(response).to redirect_to(cart_path)
    end
  end

  describe 'DELETE /cart_items/:id' do
    it '削除ができること' do
      post cart_items_path, params: { cart_item: { product_id: 1, quantity: 2 } }
      item = CartItem.last

      delete cart_item_path(item)
      expect(CartItem.count).to eq(0)
      expect(response).to redirect_to(cart_path)
    end

    it '他セッションの明細は削除できないこと' do
      post cart_items_path, params: { cart_item: { product_id: 1, quantity: 2 } }
      item = CartItem.last

      reset! # セッションをリセット

      delete cart_item_path(item)
      expect(response).to redirect_to(cart_path)
    end
  end
end
