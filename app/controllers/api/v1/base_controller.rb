class Api::V1::BaseController < ActionController::Base
  HMAC_SECRET = Rails.application.credentials.dig(:jwt, :hmac_secret) # find the secret

  skip_before_action :verify_authenticity_token
  before_action :verify_request
  include Api::V1::UsersHelper

  rescue_from JWT::ExpiredSignature, with: :render_unauthorized

  private

  def verify_request
    token = find_jwt_token
    if token.present?
      data = jwt_decode(token)

      puts "data #{data}"
      user_id = data[:user_id]
      @current_user = User.find(user_id) # set current user by user_id in JWT payload
    else
      render json: { error: 'Missing JWT token.' }, status: 401
    end
  end

  def jwt_decode(token) # decode JWT, then turn payload into a hash
    decoded_info = JWT.decode(token, HMAC_SECRET, { algorithm: 'HS256' })[0] # extract the payload
    HashWithIndifferentAccess.new decoded_info
  end

  def find_jwt_token # retrieve token from headers
    request.headers['X-USER-TOKEN']
  end

  def render_unauthorized
    render json: { error: 'token expired' }, status: 401
  end
end
