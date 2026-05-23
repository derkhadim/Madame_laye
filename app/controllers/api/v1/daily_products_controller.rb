module Api
  module V1
    class DailyProductsController < ApplicationController
      before_action :require_cook
      before_action :set_daily_product, only: [:show, :update, :destroy]

      def index
        products = current_user.daily_products
        result = paginate(products.order(date: :desc, created_at: :desc))
        render_success({ products: result[:data], meta: result[:meta] })
      end

      def show
        render_success(product_response(@daily_product))
      end

      def create
        product = current_user.daily_products.build(product_params)

        if product.save
          render_success(product_response(product), "Produit créé avec succès", :created)
        else
          render_error("Erreur de création", :unprocessable_entity, product.errors.full_messages)
        end
      end

      def update
        if @daily_product.update(product_params)
          render_success(product_response(@daily_product), "Produit mis à jour")
        else
          render_error("Erreur de mise à jour", :unprocessable_entity, @daily_product.errors.full_messages)
        end
      end

      def destroy
        @daily_product.destroy
        render_success(nil, "Produit supprimé")
      end

      private

      def set_daily_product
        @daily_product = current_user.daily_products.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Produit non trouvé", :not_found)
      end

      def product_params
        params.permit(:name, :description, :price, :quantity_available, :date, :category)
      end

      def require_cook
        require_role(:cook)
      end

      def product_response(product)
        {
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price.to_f,
          quantity_available: product.quantity_available,
          date: product.date,
          category: product.category,
          created_at: product.created_at
        }
      end
    end
  end
end
