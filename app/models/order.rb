class Order < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :cook, class_name: "User"
  belongs_to :delivery_driver, class_name: "User", optional: true

  enum :status, {
    pending: 0,
    accepted: 1,
    in_progress: 2,
    in_delivery: 3,
    delivered: 4,
    completed: 5,
    cancelled: 6,
    driver_assigned: 7
  }

  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :delivery_address, presence: true
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }

  accepts_nested_attributes_for :order_items

  scope :by_status, ->(status) { where(status: status) }
  scope :pending_orders, -> { where(status: :pending) }
  scope :today_orders, -> { where(created_at: Time.current.beginning_of_day..Time.current.end_of_day) }

  def mark_accepted!
    update(status: :accepted)
  end

  def mark_in_progress!
    update(status: :in_progress)
  end

  def assign_delivery_driver!(driver)
    update(delivery_driver: driver, status: :driver_assigned)
  end

  def accept_delivery!
    update(status: :in_delivery)
  end

  def mark_delivered!
    update(status: :delivered)
  end

  def mark_completed!
    update(status: :completed, client_received: true)
  end

  def cancel!
    update(status: :cancelled)
  end
end
