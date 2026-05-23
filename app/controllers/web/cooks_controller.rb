class Web::CooksController < WebController
  skip_before_action :authenticate_web!

  def show
    @cook = User.cook.find(params[:id])
    @weekly_meals = @cook.meals.order(day_of_week: :asc, meal_type: :asc)
    @daily_products = @cook.daily_products.for_date(Date.current).order(created_at: :desc)
  rescue ActiveRecord::RecordNotFound
    redirect_to "/menus/search", alert: "Cuisinier non trouvé"
  end
end
