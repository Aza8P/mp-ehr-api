json.user @current_user
json.bookings @bookings
json.booked_pets do
  json.partial! partial: 'api/v1/users/pet', collection: @booked_pets, as: :pet
end
