# frozen_string_literal: true

class Store < ApplicationRecord
  has_many :products, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[name code]
  end
end
