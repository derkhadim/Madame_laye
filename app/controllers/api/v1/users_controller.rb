module Api
  module V1
    class UsersController < ApplicationController
      # No before_action needed - role checks are done inline

      def show
        render_success(user_response(current_user))
      end

      def update
        if current_user.update(update_params)
          render_success(user_response(current_user), "Profil mis à jour")
        else
          render_error("Erreur de mise à jour", :unprocessable_entity, current_user.errors.full_messages)
        end
      end

      def update_location
        if current_user.update(latitude: params[:latitude], longitude: params[:longitude])
          render_success({ latitude: current_user.latitude, longitude: current_user.longitude }, "Localisation mise à jour")
        else
          render_error("Erreur de mise à jour de la localisation")
        end
      end

      def cooks_nearby
        unless params[:latitude] && params[:longitude]
          return render_error("Latitude et longitude requises")
        end

        radius = params[:radius] || 0.5
        cooks = User.nearby_cooks(params[:latitude].to_f, params[:longitude].to_f, radius.to_f)
                    .select(:id, :first_name, :last_name, :address, :latitude, :longitude, :avatar)

        render_success(cooks)
      end

      def delivery_drivers_nearby
        require_role(:cook)

        unless params[:latitude] && params[:longitude]
          return render_error("Latitude et longitude requises")
        end

        radius = params[:radius] || 1.0
        drivers = User.nearby_delivery_drivers(params[:latitude].to_f, params[:longitude].to_f, radius.to_f)
                       .select(:id, :first_name, :last_name, :phone_number, :latitude, :longitude)

        render_success(drivers)
      end

      private

      def update_params
        params.permit(:first_name, :last_name, :address, :avatar)
      end

      def require_admin_or_supervisor
        unless current_user.admin? || current_user.supervisor?
          render_error("Accès non autorisé", :forbidden)
        end
      end

      def user_response(user)
        {
          id: user.id,
          phone_number: user.phone_number,
          first_name: user.first_name,
          last_name: user.last_name,
          role: user.role,
          address: user.address,
          latitude: user.latitude,
          longitude: user.longitude,
          avatar: user.avatar,
          status: user.status,
          balance: user.balance
        }
      end
    end
  end
end
