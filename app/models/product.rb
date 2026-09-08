class Product < ApplicationRecord
  belongs_to :store
  has_one :sku, dependent: :destroy

  accepts_nested_attributes_for :sku

  validates :name, presence: true
  validates :published, inclusion: { in: [true, false] }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name published]
  end
  def self.ransackable_associations(_auth_object = nil)
    %w[sku]
  end
end
