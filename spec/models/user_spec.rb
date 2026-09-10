# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it '正常なデータの場合は有効' do
      user = User.new(
        email: 'user@example.com',
        password: 'password',
        password_confirmation: 'password',
        name: '山田太郎'
      )
      expect(user).to be_valid
    end

    it 'emailがない場合は無効' do
      user = User.new(password: 'password', password_confirmation: 'password')
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it 'ordersを持てる' do
      user = User.create!(email: 'user@example.com', password: 'password', password_confirmation: 'password')
      order = user.orders.create!(status: 'new', payment_status: 'paid')
      expect(user.orders).to include(order)
    end
  end
end
