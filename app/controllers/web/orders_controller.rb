class Web::OrdersController < WebController
  before_action :authenticate_web!

  def index
    @orders = case current_user.role
              when "cook" then current_user.orders_as_cook
              when "delivery_driver" then current_user.orders_as_delivery_driver
              else current_user.orders_as_customer
              end
    @orders = @orders.order(created_at: :desc)
  end

  def show
    @order = Order.find(params[:id])
    unless @order.customer_id == current_user.id || @order.cook_id == current_user.id || @order.delivery_driver_id == current_user.id || current_user.admin? || current_user.supervisor?
      redirect_to "/orders", alert: "Accès non autorisé"
    end
  end

  def accept
    @order = current_user.orders_as_cook.find(params[:id])
    if @order.pending?
      @order.mark_accepted!
      redirect_to "/dashboard", notice: "Commande acceptée"
    else
      redirect_to "/orders/#{@order.id}", alert: "Action impossible"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to "/orders", alert: "Commande non trouvée"
  end

  def assign
    @order = current_user.orders_as_cook.find(params[:id])
    @drivers = User.delivery_driver.active
  rescue ActiveRecord::RecordNotFound
    redirect_to "/orders", alert: "Commande non trouvée"
  end

  def assign_driver
    @order = current_user.orders_as_cook.find(params[:id])
    driver = User.delivery_driver.find(params[:driver_id])
    @order.assign_delivery_driver!(driver)
    redirect_to "/dashboard", notice: "Livreur assigné"
  rescue ActiveRecord::RecordNotFound
    redirect_to "/orders/#{@order.id}", alert: "Livreur non trouvé"
  end

  def mark_delivered
    @order = current_user.orders_as_delivery_driver.find(params[:id])
    @order.mark_delivered!
    commission = 500
    current_user.update(balance: current_user.balance + commission)
    redirect_to "/dashboard", notice: "Livrée ! Commission: #{helpers.number_to_currency(commission, unit: 'CFA', format: '%n %u')}"
  rescue ActiveRecord::RecordNotFound
    redirect_to "/orders", alert: "Commande non trouvée"
  end

  def complete
    @order = current_user.orders_as_cook.find(params[:id])
    if @order.delivered?
      @order.mark_completed!
      redirect_to "/dashboard", notice: "Commande terminée"
    else
      redirect_to "/orders/#{@order.id}", alert: "La commande doit être livrée d'abord"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to "/orders", alert: "Commande non trouvée"
  end

  def confirm_reception
    @order = current_user.orders_as_cook.find(params[:id])
    @order.update(client_received: true)
    redirect_to "/orders/#{@order.id}", notice: "Réception confirmée"
  end

  def cancel
    @order = Order.find(params[:id])
    if @order.customer_id == current_user.id || @order.cook_id == current_user.id
      @order.cancel! if @order.pending? || @order.accepted?
      redirect_to "/orders", notice: "Commande annulée"
    else
      redirect_to "/orders", alert: "Non autorisé"
    end
  end
end
