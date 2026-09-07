class Store < ApplicationRecord
  has_many :products, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
end
