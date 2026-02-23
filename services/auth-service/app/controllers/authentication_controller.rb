require 'jwt'

class AuthenticationController < ApplicationController
  include ActionController::Cookies

  before_action :authenticate_user!, only: [:validate_session]

  def validate_session
    render json: { authenticated: true, user_id: @current_user_id }, status: :ok
  end

  def signup
    data = params[:authentication].present? ? auth_params : signup_params
    user = User.new(data)

    if user.save
      token = encode_token({ user_id: user.id })
      cookies[:jwt] = {
        value: token,
        httponly: true,
        expires: 24.hours.from_now,
        path: '/',
        same_site: :lax,
        secure: false
      }
      render json: { message: 'Criado!' }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = encode_token({ user_id: user.id })

      cookies[:jwt] = {
        value: token,
        httponly: true,
        expires: 24.hours.from_now,
        path: '/',
        same_site: :lax,
        secure: false
      }

      render json: { message: 'Login OK' }, status: :ok
    else
      render json: { error: 'Incorreto' }, status: :unauthorized
    end
  end

  def logout
    # Isso envia um cabeçalho que diz ao navegador para apagar o cookie
    cookies.delete(:jwt, path: '/')
    render json: { message: 'Logged out' }, status: :ok
  end

  private

  def signup_params
    # Permite os campos direto na raiz (como o seu fetch está enviando)
    params.permit(:email, :password)
  end

  def auth_params
    # Permite os campos se vierem dentro de { authentication: { ... } }
    params.require(:authentication).permit(:email, :password)
  end

  def encode_token(payload)
    # Expira em 24 horas
    payload[:exp] = 24.hours.from_now.to_i
    JWT.encode(payload, ENV['JWT_SECRET'])
  end
end