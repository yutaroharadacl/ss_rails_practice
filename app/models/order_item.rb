class OrderItem < ApplicationRecord
  belongs_to :order

  def subtotal
    price * quantity
  end
end
