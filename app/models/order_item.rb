class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item, polymorphic: true

  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price, numericality: { greater_than: 0 }
end
