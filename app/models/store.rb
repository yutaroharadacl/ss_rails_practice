# frozen_string_literal: true

class Store < ApplicationRecord
  has_many :products, dependent: :destroy

  validates :name, presence: true
  # Rails 6.1でuniquenessのデフォルト比較が変わるため、DEPRECATION WARNING回避のため明示している
  validates :code, presence: true, uniqueness: { case_sensitive: true }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name code]
  end
end
