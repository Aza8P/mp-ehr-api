class User < ApplicationRecord
  # has_many :pets, dependent: :destroy
  has_many :bookings
  has_many :booked_pets, through: :bookings, source: :pet
end
