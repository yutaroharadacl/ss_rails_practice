# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'layouts/_sidebar', type: :view do
  context '大項目がアクティブで中項目が2個のとき' do
    before do
      menu_items = [
        {
          name: 'Products',
          children: [
            { name: '一覧', path: '/products' },
            { name: '登録', path: '/products/new' }
          ]
        }
      ].freeze
      allow(SidebarMenu).to receive(:menu_items).and_return(menu_items)
      allow(view).to receive(:current_major_menu_item).with(menu_items).and_return(menu_items.first)
      allow(view).to receive(:user_signed_in?).and_return(false)
      render
    end

    it '中項目のリンクが両方表示される' do
      expect(rendered).to include('一覧')
      expect(rendered).to include('/products')
    end
  end

  context '大項目がアクティブで中項目が1個のとき' do
    before do
      menu_items = [
        {
          name: 'Products',
          children: [
            { name: '一覧', path: '/products' }
          ]
        }
      ].freeze
      allow(SidebarMenu).to receive(:menu_items).and_return(menu_items)
      allow(view).to receive(:current_major_menu_item).with(menu_items).and_return(menu_items.first)
      allow(view).to receive(:user_signed_in?).and_return(false)
      render
    end

    it '中項目のリンクが表示されない' do
      expect(rendered).not_to include('一覧')
    end
  end
end
