module Api
  module V1
    class PaymentsController < ApplicationController
      before_action :set_order, only: [:create]

      def create
        return render_error("Action réservée aux clients") unless current_user.client?

        payment = @order.payments.build(
          customer: current_user,
          amount: @order.total_amount,
          payment_method: params[:payment_method],
          phone_number: params[:phone_number],
          status: :pending
        )

        if payment.save
          process_payment(payment)
        else
          render_error("Erreur de paiement", :unprocessable_entity, payment.errors.full_messages)
        end
      end

      def history
        payments = current_user.payments
        result = paginate(payments.order(created_at: :desc))
        render_success({ payments: result[:data].map { |p| payment_response(p) }, meta: result[:meta] })
      end

      def withdrawal
        return render_error("Action réservée aux livreurs") unless current_user.delivery_driver?

        amount = params[:amount].to_f
        if amount <= 0
          return render_error("Montant invalide")
        end

        if current_user.balance < amount
          return render_error("Solde insuffisant. Solde disponible: #{current_user.balance}")
        end

        current_user.update(balance: current_user.balance - amount)
        render_success({ balance: current_user.balance, withdrawn: amount }, "Retrait de #{amount} effectué avec succès")
      end

      def balance
        return render_error("Action réservée aux livreurs") unless current_user.delivery_driver?

        render_success({ balance: current_user.balance.to_f })
      end

      private

      def set_order
        @order = current_user.orders_as_customer.find(params[:order_id])
      rescue ActiveRecord::RecordNotFound
        render_error("Commande non trouvée", :not_found)
      end

      def process_payment(payment)
        transaction_id = "TXN-#{Time.current.to_i}-#{payment.id}"

        payment.update(
          status: :completed,
          transaction_id: transaction_id
        )

        render_success(payment_response(payment), "Paiement effectué avec succès")
      end

      def payment_response(payment)
        {
          id: payment.id,
          order_id: payment.order_id,
          payment_method: payment.payment_method,
          amount: payment.amount.to_f,
          status: payment.status,
          transaction_id: payment.transaction_id,
          phone_number: payment.phone_number,
          created_at: payment.created_at
        }
      end
    end
  end
end
