# Dakar quartiers
DAKAR_QUARTIERS = [
  "Plateau", "Médina", "Gorée", "Fass", "Colobane", "Gueule Tapée", "Fann",
  "Point E", "Amitié", "Mermoz", "Sacré-Cœur", "Liberté", "Baobab",
  "Sicap Karack", "Cité Keur Gorgui", "HLM", "Dieuppeul", "Derklé",
  "Grand Dakar", "Biscuiterie", "Patte d'Oie", "Nord Foire", "Ouest Foire",
  "Almadies", "Ngor", "Île de Ngor", "Ouakam", "Yoff", "Mamelles", "Virage",
  "Grand Yoff", "Parcelles Assainies", "Cambérène", "Hann Bel-Air", "Grand Médine",
  "Cité Mixta", "Sicap Liberté", "Soprim",
  "Liberté 1", "Liberté 2", "Liberté 3", "Liberté 4", "Liberté 5", "Liberté 6",
  "Sacré-Cœur 1", "Sacré-Cœur 2", "Sacré-Cœur 3",
  "Amitié 1", "Amitié 2", "Amitié 3",
]

puts "Loaded #{DAKAR_QUARTIERS.size} Dakar quartiers"

# Seed quartiers
puts "\nSeeding quartiers..."
DAKAR_QUARTIERS.each { |q| Quartier.find_or_create_by!(nom: q) }
puts "#{Quartier.count} quartiers created"

# Create admin user
admin = User.create!(
  phone_number: "221770000001",
  password: "password123",
  first_name: "Admin",
  last_name: "MadameLaye",
  address: "Plateau",
  latitude: 14.7167,
  longitude: -17.4677,
  role: :admin,
  status: :active
)
puts "Admin created: #{admin.phone_number}"

# Create cooks
cooks = [
  { phone: "221771234567", first: "Mariama", last: "Diallo", lat: 14.7200, lng: -17.4700, addr: "Ouakam" },
  { phone: "221772345678", first: "Aminata", last: "Sow", lat: 14.7300, lng: -17.4600, addr: "Mermoz" },
  { phone: "221773456789", first: "Fatou", last: "Diop", lat: 14.7100, lng: -17.4800, addr: "Ngor" },
  { phone: "221774567890", first: "Aïcha", last: "Ba", lat: 14.7250, lng: -17.4650, addr: "Point E" },
  { phone: "221775500001", first: "Rokhaya", last: "Gueye", lat: 14.7150, lng: -17.4550, addr: "Sacré-Cœur" },
  { phone: "221775500002", first: "Ndèye", last: "Sall", lat: 14.7350, lng: -17.4750, addr: "Almadies" },
]

cooks.each do |c|
  cook = User.create!(
    phone_number: c[:phone],
    password: "password123",
    first_name: c[:first],
    last_name: c[:last],
    address: c[:addr],
    latitude: c[:lat],
    longitude: c[:lng],
    role: :cook,
    status: :active
  )

  # Weekly meals (Mon-Sun, lunch & dinner) — real Senegalese dishes
  lunch_dishes = [
    { name: "Thiéboudiène", desc: "Riz au poisson, légumes et sauce tomate, plat national sénégalais" },
    { name: "Mafé", desc: "Riz à la sauce d'arachide avec viande et légumes" },
    { name: "Yassa Poulet", desc: "Poulet mariné au citron et oignons, servi avec du riz" },
    { name: "Cebbujën", desc: "Riz au poisson frais, sauce tiède aux légumes" },
    { name: "Soupe Kandia", desc: "Sauce gombo avec poisson et riz blanc" },
    { name: "Thiébou Yapp", desc: "Riz à la viande de bœuf parfumé" },
    { name: "Lakh", desc: "Lait caillé avec couscous de mil, dessert traditionnel" },
  ]

  dinner_dishes = [
    { name: "Dibi", desc: "Mouton grillé à la braise, servi avec oignons et moutarde" },
    { name: "Thiéré", desc: "Couscous de mil à la sauce feuilles (soup kandia)" },
    { name: "Ndambe", desc: "Niébé (haricots) à l'huile, plat végétarien riche en protéines" },
    { name: "Fataya", desc: "Beignets farcis à la viande ou au poisson, friture sénégalaise" },
    { name: "Riz Gras", desc: "Riz rouge à la viande, carottes, navets et chou" },
    { name: "Boulettes Sauce", desc: "Boulettes de viande hachée sauce tomate, riz blanc" },
    { name: "Omelette Riz", desc: "Omelette aux légumes, riz blanc et sauce" },
  ]

  Meal.day_of_weeks.keys.each_with_index do |day, idx|
    lunch = lunch_dishes[idx % lunch_dishes.length]
    dinner = dinner_dishes[idx % dinner_dishes.length]

    cook.meals.create!(
      name: lunch[:name],
      description: lunch[:desc],
      price: [3500, 4000, 5000, 6000].sample,
      day_of_week: day,
      meal_type: :lunch,
      available: true,
      portion_count: [5, 8, 10, 12, 15].sample
    )

    cook.meals.create!(
      name: dinner[:name],
      description: dinner[:desc],
      price: [4000, 5000, 6000, 7500].sample,
      day_of_week: day,
      meal_type: :dinner,
      available: true,
      portion_count: [5, 8, 10, 12, 15].sample
    )
  end

  # Daily products with real names
  products_by_category = {
    petit_fours: [
      { name: "Samoussas", desc: "Beignets triangulaires farcis à la viande hachée" },
      { name: "Nems", desc: "Rouleaux de printemps frits, farcis au poulet" },
      { name: "Pastels", desc: "Beignets de poisson à la pâte moelleuse" },
    ],
    plat_sale: [
      { name: "Sandwich Thiéboudiène", desc: "Pain garni de poisson et légumes" },
      { name: "Pain Yassa", desc: "Sandwich poulet Yassa sauce oignons" },
      { name: "Fataya Viande", desc: "Beignets farcis viande, vente à l'unité" },
    ],
    gateaux: [
      { name: "Thiakry", desc: "Dessert à base de couscous de mil et lait caillé" },
      { name: "Ngalakh", desc: "Crème de mil au lait, beurre de cacahuète et fruits" },
      { name: "Beignets", desc: "Beignets sucrés moelleux, vente à la pièce" },
    ],
  }

  DailyProduct.categories.each_key do |cat|
    items = products_by_category[cat.to_sym]
    items.each do |item|
      cook.daily_products.create!(
        name: item[:name],
        description: item[:desc],
        price: [500, 1000, 1500, 2000, 2500].sample,
        quantity_available: [10, 15, 20, 30].sample,
        date: Date.current,
        category: cat
      )
    end
  end

  puts "Cook created: #{c[:first]} #{c[:last]} (#{cook.phone_number})"
end

# Create clients
clients = [
  { phone: "221775678901", first: "Moussa", last: "Ndiaye", lat: 14.7150, lng: -17.4750, addr: "Point E" },
  { phone: "221776789012", first: "Khadija", last: "Sy", lat: 14.7220, lng: -17.4680, addr: "Grand Dakar" },
]

clients.each do |c|
  User.create!(
    phone_number: c[:phone],
    password: "password123",
    first_name: c[:first],
    last_name: c[:last],
    address: c[:addr],
    latitude: c[:lat],
    longitude: c[:lng],
    role: :client,
    status: :active
  )
  puts "Client created: #{c[:first]} #{c[:last]} (#{c[:phone]})"
end

# Create delivery drivers
drivers = [
  { phone: "221777890123", first: "Pape", last: "Gueye", lat: 14.7180, lng: -17.4720, addr: "HLM" },
  { phone: "221778901234", first: "Ousmane", last: "Faye", lat: 14.7120, lng: -17.4780, addr: "Médina" },
]

drivers.each do |d|
  User.create!(
    phone_number: d[:phone],
    password: "password123",
    first_name: d[:first],
    last_name: d[:last],
    address: d[:addr],
    latitude: d[:lat],
    longitude: d[:lng],
    role: :delivery_driver,
    status: :active,
    balance: 0
  )
  puts "Driver created: #{d[:first]} #{d[:last]} (#{d[:phone]})"
end

# Create some sample orders and reviews
puts "\nCreating sample orders..."
cook_ids = User.cook.ids
client_ids = User.client.ids
driver_ids = User.delivery_driver.ids

# Each client orders from a random cook
client_ids.each_with_index do |client_id, ci|
  cook_id = cook_ids[ci % cook_ids.length]
  cook = User.find(cook_id)
  client = User.find(client_id)
  today_day = Date.current.strftime("%A").downcase

  available_meals = cook.meals.available.where(day_of_week: Meal.day_of_weeks[today_day])
  next if available_meals.empty?

  meal = available_meals.sample

  order = Order.create!(
    customer: client,
    cook: cook,
    status: [:pending, :accepted, :in_delivery, :delivered].sample,
    delivery_address: client.address,
    delivery_latitude: client.latitude,
    delivery_longitude: client.longitude,
    total_amount: meal.price * 2,
    notes: "Merci bien !",
    client_received: false
  )

  OrderItem.create!(
    order: order,
    item: meal,
    quantity: 2,
    unit_price: meal.price
  )

  puts "  Order ##{order.id}: #{client.full_name} ← #{meal.name} (#{cook.full_name})"

  # Add a review if delivered
  if order.delivered?
    Review.create!(
      user: client,
      meal: meal,
      order: order,
      rating: [3, 4, 5].sample,
      comment: ["Délicieux !", "Très bon plat, je recommande", "Parfait, merci !", "Excellent, à refaire !"].sample
    )
    puts "    ★ Review: #{Review.last.rating}/5"
  end
end

puts "\nSeed completed!"
puts "Quartiers count: #{Quartier.count}"
puts "Cooks count: #{User.cook.count}"
puts "Clients count: #{User.client.count}"
puts "Drivers count: #{User.delivery_driver.count}"
puts "Meals count: #{Meal.count}"
puts "Daily products count: #{DailyProduct.count}"
puts "Orders count: #{Order.count}"
puts "Reviews count: #{Review.count}"
