module Api
  module V1
    class MenusController < ApplicationController
      skip_before_action :authenticate_request, only: [:search]

      def search
        keyword = params[:keyword]&.strip&.downcase
        meal_type_filter = params[:meal_type].presence
        today = Date.current.strftime("%A").downcase
        base_meals = Meal.available.where(day_of_week: Meal.day_of_weeks[today])

        meals = if keyword.present?
          base_meals.where("LOWER(name) LIKE ?", "%#{keyword}%")
        else
          base_meals.limit(10)
        end

        meals = meals.where(meal_type: meal_type_filter) if meal_type_filter.present?

        results = meals.group_by(&:user).map do |cook, cook_meals|
          {
            cook: {
              id: cook.id, first_name: cook.first_name, last_name: cook.last_name,
              address: cook.address, latitude: cook.latitude, longitude: cook.longitude, avatar: cook.avatar
            },
            menus: cook_meals.map { |m|
              {
                id: m.id, name: m.name, description: m.description, price: m.price.to_f,
                meal_type: m.meal_type, average_rating: m.average_rating, reviews_count: m.reviews.count
              }
            }
          }
        end

        render_success(results)
      end
    end
  end
end
