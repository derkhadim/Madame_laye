module Api
  module V1
    class WithdrawalsController < ApplicationController
      def index
        # Drivers see their own history; admins see all pending
        withdrawals = if current_user.delivery_driver?
          current_user.withdrawals
        elsif current_user.admin? || current_user.supervisor?
          Withdrawal.all
        else
          return render_error("Accès non autorisé", :forbidden)
        end

        result = paginate(withdrawals.recent)
        render_success(result[:data].map { |w| withdrawal_response(w) })
      end

      def validate
        return render_error("Action réservée aux administrateurs", :forbidden) unless current_user.admin? || current_user.supervisor?

        withdrawal = Withdrawal.pending.find(params[:id])
        user = withdrawal.user

        if user.balance < withdrawal.amount
          return render_error("Solde insuffisant pour valider ce retrait")
        end

        user.update!(balance: user.balance - withdrawal.amount)
        withdrawal.update!(status: :validated, processed_at: Time.current)

        render_success(withdrawal_response(withdrawal), "Retrait validé")
      rescue ActiveRecord::RecordNotFound
        render_error("Retrait non trouvé", :not_found)
      end

      private

      def withdrawal_response(withdrawal)
        {
          id: withdrawal.id,
          amount: withdrawal.amount.to_f,
          status: withdrawal.status,
          processed_at: withdrawal.processed_at,
          created_at: withdrawal.created_at,
          user: {
            id: withdrawal.user.id,
            first_name: withdrawal.user.first_name,
            last_name: withdrawal.user.last_name,
            phone_number: withdrawal.user.phone_number,
            balance: withdrawal.user.balance.to_f
          }
        }
      end
    end
  end
end
