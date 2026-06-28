class Quartier < ApplicationRecord
  validates :nom, presence: true, uniqueness: true
end
