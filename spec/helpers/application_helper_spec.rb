# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#current_major_menu_item' do
    let(:menu_items) { SidebarMenu.menu_items }

    context '現在のパスが中項目のpathと一致するとき' do
      it '対応する大項目を返す' do
        request = ActionDispatch::TestRequest.create
        request.path_info = '/products'
        allow(helper).to receive(:request).and_return(request)

        expect(helper.current_major_menu_item(menu_items)).to eq(menu_items.first)
      end
    end

    context 'どの中項目にも一致しないとき' do
      it 'nilを返す' do
        request = ActionDispatch::TestRequest.create
        request.path_info = '/nowhere'
        allow(helper).to receive(:request).and_return(request)

        expect(helper.current_major_menu_item(menu_items)).to eq(nil)
      end
    end
  end
end
