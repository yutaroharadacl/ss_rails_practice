# frozen_string_literal: true

module Admin
  module OrdersHelper
    def orders_status_label(status)
      Order::STATUS_LABELS[status]
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
