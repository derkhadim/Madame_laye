class Web::MealsController < WebController
  before_action :authenticate_web!
  before_action -> { require_role(:cook) }

  def index
    @meals = current_user.meals.order(day_of_week: :asc, meal_type: :asc)
  end

  def new
    @meal = current_user.meals.build
  end

  def create
    @meal = current_user.meals.build(meal_params)
    if @meal.save
      redirect_to "/meals", notice: "Plat ajouté"
    else
      @errors = @meal.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @meal = current_user.meals.find(params[:id])
  end

  def update
    @meal = current_user.meals.find(params[:id])
    if @meal.update(meal_params)
      redirect_to "/meals", notice: "Plat mis à jour"
    else
      @errors = @meal.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meal = current_user.meals.find(params[:id])
    @meal.destroy
    redirect_to "/meals", notice: "Plat supprimé"
  end

  private

  def meal_params
    params.permit(:name, :description, :price, :day_of_week, :meal_type, :available, :portion_count)
  end
end
