json.extract! pet, :id, :name, :species, :age, :gender, :image_url, :neutered, :vaccinated, :special_need, :size, :description, :adoptable
if pet.image.attached? 
  json.image_url pet.image.url
end
