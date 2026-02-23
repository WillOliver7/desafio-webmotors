require 'jwt'

class ApplicationController < ActionController::API
  include ActionController::Cookies

  def authenticate_user!
    token = cookies[:jwt]
    begin
      decoded = JWT.decode(token, ENV['JWT_SECRET'], true, { algorithm: 'HS256' })
      @current_user_id = decoded[0]['user_id']
    rescue
      render json: { error: 'Não autorizado' }, status: :unauthorized
    end
  end

  def current_user_id
    @current_user_id
  end
end
