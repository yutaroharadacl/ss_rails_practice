# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::OrderItems', type: :request do
  let!(:order) { Order.create(status: 'new') }
  let!(:store) { Store.create!(name: '店舗', code: 'STORE') }
  let!(:product) { create_product!(store: store, name: 'りんご', code: 'APPLE', sku_attributes: { price: 1000 }) }

  # 追加後は同じ絞り込み状態でモーダルを開き直せるようにリダイレクトする
  def items_tab_path(reopen: false, search: nil)
    options = { anchor: 'tab-items' }
    options.merge!(open_modal: 1, q: search) if reopen
    admin_order_path(order, options.compact)
  end

  describe 'GET /admin/orders/:order_id/order_items/new' do
    let!(:other_product) do
      create_product!(store: store, name: 'みかん', code: 'ORANGE', sku_attributes: { price: 2000 })
    end

    it '商品候補がJSとして返る' do
      get new_admin_order_order_item_path(order), xhr: true

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/javascript')
      expect(response.body).to include('product-list')
      expect(response.body).to include('りんご')
      expect(response.body).to include('みかん')
    end

    it 'すでに追加済みの商品は候補に出ない' do
      order.order_items.create!(product_id: product.id, quantity: 1, price: 1000)
      get new_admin_order_order_item_path(order), xhr: true

      expect(response.body).not_to include('りんご')
      expect(response.body).to include('みかん')
    end

    it 'SKUが無い商品は単価を決められないので候補に出ない' do
      product.sku.destroy!
      get new_admin_order_order_item_path(order), xhr: true

      expect(response.body).not_to include('りんご')
      expect(response.body).to include('みかん')
    end

    it '商品名で絞り込める' do
      get new_admin_order_order_item_path(order), params: { q: { name_cont: 'みか' } }, xhr: true

      expect(response.body).to include('みかん')
      expect(response.body).not_to include('りんご')
    end

    it 'SKUコードで絞り込める' do
      get new_admin_order_order_item_path(order), params: { q: { sku_code_cont: 'APPLE' } }, xhr: true

      expect(response.body).to include('りんご')
      expect(response.body).not_to include('みかん')
    end

    it '該当がない場合はその旨が表示される' do
      get new_admin_order_order_item_path(order), params: { q: { name_cont: '存在しない商品' } }, xhr: true

      expect(response.body).to include('該当する商品がありません')
    end

    it 'UIに無い検索述語は許可リストで捨てられる' do
      get new_admin_order_order_item_path(order), params: { q: { sku_price_eq: 1000 } }, xhr: true

      expect(response).to have_http_status(:success)
      expect(response.body).to include('りんご')
      expect(response.body).to include('みかん')
    end

    it '桁あふれする受注IDを渡されてもエラー画面にならない' do
      get new_admin_order_order_item_path(order_id: '9' * 30), xhr: true

      expect(response).to redirect_to(admin_orders_path)
      expect(flash[:alert]).to eq(I18n.t('flash.admin.orders.error.not_found'))
    end

    context 'statusがcompleteの場合' do
      let!(:order) { Order.create(status: 'complete') }

      it '受注詳細へリダイレクトされる' do
        get new_admin_order_order_item_path(order), xhr: true

        expect(response).to redirect_to(items_tab_path)
      end
    end
  end

  describe 'POST /admin/orders/:order_id/order_items' do
    context 'statusがnewの場合' do
      it '受注商品が追加される' do
        expect do
          post admin_order_order_items_path(order), params: { order_item: { product_id: product.id, quantity: 2 } }
        end.to change(OrderItem, :count).by(1)

        order_item = order.order_items.last
        expect(order_item.product_id).to eq(product.id)
        expect(order_item.quantity).to eq(2)
      end

      # permitに:priceが混入した場合と、SKU価格の適用処理が失われた場合の両方を検知する
      it '単価はフォームの値ではなくSKUの価格が設定される' do
        post admin_order_order_items_path(order),
             params: { order_item: { product_id: product.id, quantity: 1, price: 1 } }

        expect(order.order_items.last.price).to eq(product.sku.price)
      end

      it 'モーダルを開いた状態の受注商品管理タブへリダイレクトし、成功メッセージが表示される' do
        post admin_order_order_items_path(order), params: { order_item: { product_id: product.id, quantity: 1 } }

        expect(response).to redirect_to(items_tab_path(reopen: true))
        expect(flash[:notice]).to eq(I18n.t('flash.admin.order_items.create.notice'))
      end

      it '検索条件を引き継いでリダイレクトする' do
        post admin_order_order_items_path(order),
             params: { order_item: { product_id: product.id, quantity: 1 }, q: { name_cont: 'りんご' } }

        expect(response).to redirect_to(items_tab_path(reopen: true, search: { name_cont: 'りんご' }))
      end

      it '個数が0の場合は追加されない' do
        expect do
          post admin_order_order_items_path(order), params: { order_item: { product_id: product.id, quantity: 0 } }
        end.to change(OrderItem, :count).by(0)

        expect(flash[:alert]).to be_present
      end
    end

    context 'すでに同じ商品が追加されている場合' do
      before { order.order_items.create!(product_id: product.id, quantity: 1, price: 1000) }

      it '重複して追加されない' do
        expect do
          post admin_order_order_items_path(order), params: { order_item: { product_id: product.id, quantity: 1 } }
        end.to change(OrderItem, :count).by(0)

        expect(response).to redirect_to(items_tab_path(reopen: true))
        expect(flash[:alert]).to be_present
      end
    end

    context '一意制約違反が起きた場合' do
      it '500にならず重複メッセージでリダイレクトされる' do
        allow_any_instance_of(OrderItem).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)

        post admin_order_order_items_path(order), params: { order_item: { product_id: product.id, quantity: 1 } }

        expect(response).to redirect_to(items_tab_path(reopen: true))
        expect(flash[:alert]).to eq(I18n.t('flash.admin.order_items.error.duplicate'))
      end
    end

    context 'statusがcompleteの場合' do
      let!(:order) { Order.create(status: 'complete') }

      it '受注商品は追加されない' do
        expect do
          post admin_order_order_items_path(order), params: { order_item: { product_id: product.id, quantity: 1 } }
        end.to change(OrderItem, :count).by(0)

        expect(response).to redirect_to(items_tab_path)
        expect(flash[:alert]).to eq(I18n.t('flash.admin.orders.error.not_editable'))
      end
    end

    context '存在しない受注を指定した場合' do
      it '受注一覧へリダイレクトされる' do
        expect do
          post admin_order_order_items_path(order_id: 0),
               params: { order_item: { product_id: product.id, quantity: 1 } }
        end.to change(OrderItem, :count).by(0)

        expect(response).to redirect_to(admin_orders_path)
        expect(flash[:alert]).to eq(I18n.t('flash.admin.orders.error.not_found'))
      end
    end

    context '存在しない商品を指定した場合' do
      it 'バリデーションエラーになり追加されない' do
        expect do
          post admin_order_order_items_path(order), params: { order_item: { product_id: 0, quantity: 1 } }
        end.to change(OrderItem, :count).by(0)

        expect(response).to redirect_to(items_tab_path(reopen: true))
        expect(flash[:alert]).to be_present
      end
    end

    context 'SKUが削除された商品を指定した場合' do
      it '500にならずバリデーションエラーとして扱われる' do
        product.sku.destroy!

        expect do
          post admin_order_order_items_path(order), params: { order_item: { product_id: product.id, quantity: 1 } }
        end.to change(OrderItem, :count).by(0)

        expect(response).to redirect_to(items_tab_path(reopen: true))
        expect(flash[:alert]).to be_present
      end
    end
  end
end
