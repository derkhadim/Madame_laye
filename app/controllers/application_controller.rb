class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last

    if token.blank?
      render json: { error: "Token manquant" }, status: :unauthorized
      return
    end

    begin
      decoded = JwtService.decode(token)
      @current_user = User.find(decoded[:user_id])
    rescue JWT::ExpiredSignature => e
      render json: { error: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { error: e.message }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Utilisateur non trouvé" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def require_role(*roles)
    unless roles.include?(@current_user.role.to_sym)
      render json: { error: "Accès non autorisé pour ce rôle" }, status: :forbidden
    end
  end

  def paginate(collection)
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 20).to_i.clamp(1, 100)
    total = collection.count

    {
      data: collection.offset((page - 1) * per_page).limit(per_page),
      meta: {
        current_page: page,
        per_page: per_page,
        total_count: total,
        total_pages: (total.to_f / per_page).ceil
      }
    }
  end

  def render_success(data = nil, message = "Succès", status = :ok)
    render json: { success: true, message: message, data: data }, status: status
  end

  def render_error(message = "Erreur", status = :unprocessable_entity, errors = nil)
    response = { success: false, message: message }
    response[:errors] = errors if errors
    render json: response, status: status
  end
end
