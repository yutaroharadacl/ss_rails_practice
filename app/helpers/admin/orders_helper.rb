# frozen_string_literal: true

module Admin
  module OrdersHelper
    def orders_status_label(status)
      status == 'complete' ? '完了' : '新規'
    end

    def payment_status_label(status)
      case status
      when 'pending' then '支払い待ち'
      when 'paid' then '支払い済み'
      when 'failed' then '決済失敗'
      end
    end
  end
end
