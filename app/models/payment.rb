class Payment < ApplicationRecord
  belongs_to :order
  belongs_to :customer, class_name: "User"

  enum :payment_method, {
    wave: 0,
    orange_money: 1,
    visa: 2,
    mastercard: 3
  }

  enum :status, {
    pending: 0,
    completed: 1,
    failed: 2,
    refunded: 3
  }

  validates :amount, numericality: { greater_than: 0 }
  validates :payment_method, presence: true
  validates :transaction_id, uniqueness: true, allow_nil: true
end
