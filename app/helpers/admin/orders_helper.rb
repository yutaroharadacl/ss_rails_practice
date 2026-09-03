# frozen_string_literal: true

module Admin
  module OrdersHelper
    def orders_status_label(status)
      status == 'complete' ? '完了' : '新規'
    end
  end
end
