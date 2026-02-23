class AuthenticationController < ApplicationController
  include ActionController::Cookies

  def signup
    # Tenta pegar de dentro de :authentication ou direto do topo
    data = params[:authentication].present? ? auth_params : signup_params
    user = User.new(data)

    if user.save
      token = encode_token({ user_id: user.id })
      set_cookie(token) # Sua função de setar cookie
      render json: { message: 'Criado!' }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = encode_token({ user_id: user.id })
      
      # Define o cookie no browser
      cookies.signed[:jwt] = {
        value: token,
        httponly: true,    # O JavaScript não consegue ler
        expires: 24.hours.from_now,
        path: '/'
      }

      render json: { message: 'Login realizado com sucesso', user: { email: user.email } }, status: :ok
    else
      render json: { error: 'Incorreto' }, status: :unauthorized
    end
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