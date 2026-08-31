# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#current_major_menu_item' do
    context '現在のパスが中項目のpathと一致するとき' do
      it '対応する大項目を返す' do
        request = ActionDispatch::TestRequest.create
        request.path_info = '/'
        allow(helper).to receive(:request).and_return(request)

        expect(helper.current_major_menu_item).to eq(SidebarMenu::MENU_ITEMS.first)
      end
    end

    context 'どの中項目にも一致しないとき' do
      it 'nilを返す' do
        request = ActionDispatch::TestRequest.create
        request.path_info = '/nowhere'
        allow(helper).to receive(:request).and_return(request)

        expect(helper.current_major_menu_item).to eq(nil)
      end
    end
  end
end
