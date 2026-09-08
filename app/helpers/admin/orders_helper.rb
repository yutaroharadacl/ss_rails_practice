# frozen_string_literal: true

module Admin
  module OrdersHelper
    def orders_status_label(status)
      status == 'complete' ? '完了' : '新規'
    end

    def payment_status_label(status)
      {
        'pending' => '支払い待ち',
        'paid' => '支払い済み',
        'failed' => '決済失敗'
      }[status]
    end
  end
end
