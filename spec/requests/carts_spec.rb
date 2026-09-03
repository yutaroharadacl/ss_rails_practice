# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Carts', type: :request do
  describe 'GET /cart' do
    it 'returns http success' do
      get cart_path
      expect(response).to have_http_status(:success)
    end

    it 'カートが空のときは空のメッセージを表示する' do
      get cart_path
      expect(response.body).to include('カートは空です')
    end

    it '初回アクセスするだけではカートを作成しない' do
      expect { get cart_path }.not_to change(Cart, :count)
    end

    it '明細があるとき、一覧が表示される' do
      post cart_items_path, params: { cart_item: { product_id: 1, quantity: 2 } } # Cartに商品を追加

      get cart_path # 再描画
      expect(response.body).to include('商品名') # 商品名が表示される
      expect(response.body).to include('2') # 数量が表示される
    end
  end
end
