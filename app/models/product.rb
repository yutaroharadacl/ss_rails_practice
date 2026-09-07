class Product < ApplicationRecord
  belongs_to :store
  has_one :sku, dependent: :destroy

  accepts_nested_attributes_for :sku

  validates :name, presence: true
  validates :published, inclusion: { in: [true, false] }
end
