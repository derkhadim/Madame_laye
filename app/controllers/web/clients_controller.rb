class Web::ClientsController < WebController
  skip_before_action :authenticate_web!, only: [:search]
  before_action -> { require_role(:client) }, only: [:order, :create_order]

  def search
    keyword = params[:keyword]&.strip&.downcase
    meal_type_filter = params[:meal_type].presence
    today = Date.current.strftime("%A").downcase
    base_meals = Meal.available.where(day_of_week: Meal.day_of_weeks[today])
    base_meals = base_meals.where(meal_type: meal_type_filter) if meal_type_filter.present?

    meals = if keyword.present?
      base_meals.where("LOWER(name) LIKE ?", "%#{keyword}%")
    else
      base_meals.limit(10)
    end

    @results = meals.group_by(&:user).map { |cook, m| { cook: cook, meals: m, products: [] } }

    if keyword.present?
      matching_products = DailyProduct.for_date(Date.current).available
        .where("LOWER(name) LIKE ?", "%#{keyword}%")
        .order(created_at: :desc)

      matching_products.group_by(&:user).each do |cook, prods|
        existing = @results.find { |r| r[:cook].id == cook.id }
        if existing
          existing[:products] = prods
        else
          @results << { cook: cook, meals: [], products: prods }
        end
      end
    end
  end

  def order
    @cook = User.cook.find(params[:cook_id])
    @item = find_item

    redirect_to "/cooks/#{@cook.id}", alert: "Article non disponible" unless @item
  end

  def create_order
    @cook = User.cook.find(params[:cook_id])

    quantity = params[:quantity].to_i
    quantity = 1 if quantity < 1

    item = find_item
    return redirect_to "/cooks/#{@cook.id}", alert: "Article non trouvé" unless item

    total = item.price * quantity

    order = current_user.orders_as_customer.build(
      cook: @cook,
      status: :pending,
      delivery_address: params[:delivery_address].presence || current_user.address,
      delivery_latitude: params[:delivery_latitude].presence&.to_f || current_user.latitude,
      delivery_longitude: params[:delivery_longitude].presence&.to_f || current_user.longitude,
      notes: params[:notes],
      total_amount: total
    )

    order.order_items.build(
      item: item,
      quantity: quantity,
      unit_price: item.price
    )

    if order.save
      redirect_to "/orders/#{order.id}", notice: "Commande créée ! Veuillez payer pour confirmer."
    else
      redirect_to "/clients/#{@cook.id}/order/#{params[:item_type]}/#{params[:item_id]}",
                  alert: "Erreur: #{order.errors.full_messages.join(', ')}"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to "/menus/search", alert: "Élément non trouvé"
  end

  private

  def find_item
    case params[:item_type]
    when "meal"
      today = Date.current.strftime("%A").downcase
      @cook.meals.available.for_day(today).find_by(id: params[:item_id])
    when "product"
      @cook.daily_products.for_date(Date.current).available.find_by(id: params[:item_id])
    end
  end
end
