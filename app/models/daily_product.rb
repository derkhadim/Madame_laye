class DailyProduct < ApplicationRecord
  belongs_to :user

  enum :category, {
    petit_fours: 0,
    plat_sale: 1,
    gateaux: 2
  }

  has_many :order_items, as: :item, dependent: :destroy

  validates :name, :price, :category, :date, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :quantity_available, numericality: { greater_than_or_equal_to: 0 }

  scope :available, -> { where("quantity_available > 0") }
  scope :for_date, ->(date) { where(date: date) }
end
