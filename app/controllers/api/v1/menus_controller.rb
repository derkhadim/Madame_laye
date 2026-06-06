module Api
  module V1
    class MenusController < ApplicationController
      skip_before_action :authenticate_request, only: [:search]

      def search
        keyword = params[:keyword]&.strip&.downcase
        meal_type_filter = params[:meal_type].presence
        today = Date.current.strftime("%A").downcase
        base_meals = Meal.available.where(day_of_week: Meal.day_of_weeks[today])
        base_meals = base_meals.where(meal_type: meal_type_filter) if meal_type_filter.present?

        if keyword.present?
          terms = keyword.split(/\s+/).map { |t| ActiveRecord::Base.sanitize_sql_like(t) }
          conditions = terms.map { |t| "(LOWER(meals.name) LIKE ? OR LOWER(meals.description) LIKE ?)" }.join(" OR ")
          bindings = terms.flat_map { |t| ["%#{t}%", "%#{t}%"] }
          cook_conditions = terms.map { |t| "(LOWER(users.first_name) LIKE ? OR LOWER(users.last_name) LIKE ?)" }.join(" OR ")
          cook_bindings = terms.flat_map { |t| ["%#{t}%", "%#{t}%"] }

          meals = base_meals.joins(:user).where("(#{conditions}) OR (#{cook_conditions})", *bindings, *cook_bindings)
        else
          meals = base_meals.limit(10)
        end

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
