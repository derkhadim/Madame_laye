class Web::DailyProductsController < WebController
  before_action :authenticate_web!
  before_action -> { require_role(:cook) }

  def index
    @products = current_user.daily_products.order(date: :desc)
  end

  def new
    @product = current_user.daily_products.build
  end

  def create
    @product = current_user.daily_products.build(product_params)
    if @product.save
      redirect_to "/daily_products", notice: "Produit ajouté"
    else
      @errors = @product.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @product = current_user.daily_products.find(params[:id])
    @product.destroy
    redirect_to "/daily_products", notice: "Produit supprimé"
  end

  private

  def product_params
    params.permit(:name, :description, :price, :quantity_available, :date, :category)
  end
end
