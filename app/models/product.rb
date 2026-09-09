# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :store
  has_one :sku, dependent: :destroy
  has_many :cart_items, dependent: :restrict_with_error

  accepts_nested_attributes_for :sku

  validates :name, presence: true
  validates :sku, presence: true
  validates :published, inclusion: { in: [true, false] }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name published]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[sku store]
  end
end
