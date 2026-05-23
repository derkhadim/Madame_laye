class User < ApplicationRecord
  has_secure_password

  enum :role, {
    client: 0,
    cook: 1,
    delivery_driver: 2,
    admin: 3,
    supervisor: 4
  }

  enum :status, {
    active: 0,
    inactive: 1,
    suspended: 2
  }

  has_many :meals, dependent: :destroy
  has_many :daily_products, dependent: :destroy
  has_many :orders_as_customer, class_name: "Order", foreign_key: :customer_id, dependent: :destroy
  has_many :orders_as_cook, class_name: "Order", foreign_key: :cook_id, dependent: :destroy
  has_many :orders_as_delivery_driver, class_name: "Order", foreign_key: :delivery_driver_id, dependent: :nullify
  has_many :reviews, dependent: :destroy
  has_many :payments, foreign_key: :customer_id, dependent: :destroy
  has_many :withdrawals, dependent: :destroy

  validates :phone_number, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  validates :role, presence: true
  validates :first_name, :last_name, presence: true
  validates :latitude, :longitude, presence: true, if: -> { cook? || delivery_driver? }

  geocoded_by :address
  after_validation :geocode, if: -> { address_changed? && !latitude_changed? && !longitude_changed? }

  scope :nearby_cooks, ->(lat, lng, radius_in_km = 0.5) {
    where(role: :cook, status: :active)
      .where("earth_distance(ll_to_earth(?, ?), ll_to_earth(latitude, longitude)) <= ?", lat, lng, radius_in_km * 1000)
  }

  scope :nearby_delivery_drivers, ->(lat, lng, radius_in_km = 1.0) {
    where(role: :delivery_driver, status: :active)
      .where("earth_distance(ll_to_earth(?, ?), ll_to_earth(latitude, longitude)) <= ?", lat, lng, radius_in_km * 1000)
  }

  def full_name
    "#{first_name} #{last_name}"
  end
end
