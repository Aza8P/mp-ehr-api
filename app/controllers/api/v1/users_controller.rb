class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :verify_request, only: [:login]
  before_action :verify_admin, only: [:admin_page]

  def profile_page
    current_user = @current_user
    @bookings = current_user.bookings
    @booked_pets = @bookings.map(&:pet)
  end

  def admin_page
    @bookings = Booking.includes(:user, :pet).all
    puts "admin_page"
    @users=[]
    @bookings.each do |booking|
      user = @users.find { |u| u[:id] == booking.user.id }
      if user.nil?
        user = {
          id: booking.user.id,
          name: booking.user.name,
          image: booking.user.image,
          wechat_id: booking.user.wechat_id,
          booked_pets: []
        }
        @users << user
      end
      pet = {
        name: booking.pet.name,
        image_url: booking.pet.image_url,
        id: booking.pet.id,
      }
      user[:booked_pets] << pet
    end
    render json: @users
  end

  def login
    code = params[:code]
    p code
    app_id = Rails.application.credentials.dig(:wechat, :app_id)
    app_secret = Rails.application.credentials.dig(:wechat, :app_secret)

    url = "https://api.weixin.qq.com/sns/jscode2session?appid=#{app_id}&secret=#{app_secret}&js_code=#{code}&grant_type=authorization_code"
    response = RestClient.get(url)
    response = JSON.parse(response.body)
    open_id = response["openid"]

    user =  User.find_or_create_by(open_id: open_id)

    payload = {user_id: user.id}
    token = jwt_encode(payload)
  
    # 4.2 - Render the response for the front-end
    render json: {
      headers: { "X-USER-TOKEN" => token },
      user: user
    }
  end

  private

  def jwt_encode(payload) # generate JWT
    payload[:exp] = 7.days.from_now.to_i # set expiration date to 7 days from now
    JWT.encode payload, HMAC_SECRET, 'HS256'
  end

  def verify_admin
    if @current_user.admin == false or nil?
      render json: {error: "You are not admin"}, status: :unauthorized
    end
  end

end
