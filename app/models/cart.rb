# frozen_string_literal: true

class Cart < ApplicationRecord
  # CartとCartItemは1対多の関係、Cartが削除されればそれに紐づくCartItemも削除されるべき
  has_many :cart_items, dependent: :destroy
end
