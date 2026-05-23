class Web::DashboardController < WebController
  before_action :authenticate_web!

  def index
    @user = current_user

    case @user.role
    when "cook"
      @pending_orders = @user.orders_as_cook.pending_orders.count
      @in_progress_orders = @user.orders_as_cook.where(status: [:accepted, :in_progress, :in_delivery]).count
      @today_meals = @user.meals.available.count
      @today_orders = @user.orders_as_cook.today_orders
      render :cook_dashboard
    when "client"
      @active_orders = @user.orders_as_customer.where.not(status: [:delivered, :completed, :cancelled])
      @order_history = @user.orders_as_customer.where(status: [:delivered, :completed]).limit(5)
      render :client_dashboard
    when "delivery_driver"
      @available_orders = Order.where(status: :accepted).count
      @my_deliveries = @user.orders_as_delivery_driver.where(status: [:in_delivery, :delivered])
      @balance = @user.balance
      render :driver_dashboard
    when "admin", "supervisor"
      @total_cooks = User.cook.count
      @total_clients = User.client.count
      @total_drivers = User.delivery_driver.count
      @total_orders = Order.count
      @pending_orders = Order.pending_orders.count
      render :admin_dashboard
    end
  end
end
