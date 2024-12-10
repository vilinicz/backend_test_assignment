json.data do
  json.array! @cars do |car|
    json.id car.id
    json.brand do
      json.id car.brand.id
      json.name car.brand.name
    end
    json.model car.model
    json.price car.price
    json.rank_score car.rank_score
    json.label car.label
  end
end
