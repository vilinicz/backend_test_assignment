BRANDS_DATA = JSON.parse(File.read('db/brands.json'))
CARS_DATA = JSON.parse(File.read('db/cars.json'))

BRANDS = BRANDS_DATA.each.with_object({}) do |brand_item, memo|
  brand_name = brand_item['name']
  memo[brand_name] = Brand.create!(name: brand_name)
end

CARS_DATA.each do |car_item|
  Car.create!(
    model: car_item['model'],
    brand: BRANDS[car_item['brand_name']],
    price: car_item['price'],
  )
end

# Uncomment and run "rake db:reset" to test app with a large dataset
# now = Time.now
# cars = []
# Car.transaction do
#   1_000_000.times do |i|
#     car = CARS_DATA.sample
#     cars.push({
#                 model: car['model'],
#                 brand_id: BRANDS[car['brand_name']].id,
#                 price: rand(10_000...100_000),
#                 created_at: now,
#                 updated_at: now,
#               })
#     if cars.size == 10000
#       Car.insert_all(cars)
#       cars = []
#     end
#   end
# end

User.create!(
  email: 'example@mail.com',
  preferred_price_range: 35_000...40_000,
  preferred_brands: [BRANDS['Alfa Romeo'], BRANDS['Volkswagen']],
)
