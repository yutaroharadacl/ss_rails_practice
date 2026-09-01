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

    it '初回アクセスでCartが作られる' do
      expect { get cart_path }.to change(Cart, :count).by(1)
    end

    it '2回目のアクセスでは新しいCartが作られない' do
      get cart_path
      expect { get cart_path }.not_to change(Cart, :count)
    end

    it '明細があるとき、一覧が表示される' do
      get cart_path # 初回アクセスでCartが作られる
      cart = Cart.find(session[:cart_id]) # 作成されたCartを取得
      cart.cart_items.create!(product_id: 1, quantity: 2) # Cartに商品を追加

      get cart_path # 2回目のアクセスでは新しいCartが作られない
      expect(response.body).to include('商品名') # 商品名が表示される
      expect(response.body).to include('2') # 数量が表示される
    end
  end
end
