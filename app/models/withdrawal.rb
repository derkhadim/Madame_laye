class Withdrawal < ApplicationRecord
  belongs_to :user

  enum :status, {
    pending: 0,
    validated: 1
  }

  validates :amount, numericality: { greater_than: 0 }
  scope :recent, -> { order(created_at: :desc) }
end
