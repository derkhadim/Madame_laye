class Web::PaymentsController < WebController
  before_action :authenticate_web!

  def new
    @order = current_user.orders_as_customer.find(params[:order_id])
    if @order.payments.exists?(status: :completed)
      redirect_to "/orders/#{@order.id}", alert: "Déjà payé"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to "/orders", alert: "Commande non trouvée"
  end

  def create
    @order = current_user.orders_as_customer.find(params[:order_id])
    payment = @order.payments.build(
      customer: current_user,
      amount: @order.total_amount,
      payment_method: params[:payment_method],
      phone_number: params[:phone_number],
      status: :completed,
      transaction_id: "WEB-#{Time.current.to_i}-#{@order.id}"
    )
    if payment.save
      redirect_to "/orders/#{@order.id}", notice: "Paiement effectué avec succès"
    else
      redirect_to "/orders/#{@order.id}/payments/new", alert: "Erreur de paiement"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to "/orders", alert: "Commande non trouvée"
  end

  def balance
    require_role(:delivery_driver)
    @balance = current_user.balance
    @pending_withdrawals = current_user.withdrawals.pending.sum(:amount)
  end

  def withdrawal
    require_role(:delivery_driver)
    amount = params[:amount].to_f
    if amount <= 0
      redirect_to "/payments/balance", alert: "Montant invalide"
    elsif current_user.balance - current_user.withdrawals.pending.sum(:amount) < amount
      redirect_to "/payments/balance", alert: "Solde insuffisant (retraits en attente inclus)"
    else
      current_user.withdrawals.create!(amount: amount, status: :pending)
      redirect_to "/withdrawals", notice: "Demande de retrait de #{helpers.number_to_currency(amount, unit: 'CFA', format: '%n %u')} soumise"
    end
  end

  def withdrawals
    require_role(:delivery_driver)
    @withdrawals = current_user.withdrawals.recent
  end
end
