class ApplicationController < ActionController::API
  #runs this function before passing over to the users index controller
  before_action :authenticate_user!

  def authenticate_user!
    render json: { errors: ['Unauthorised']}, status: 401 unless
    user_signed_in?
  end

  def user_signed_in?
    !!current_user
  end

  def current_user
    @current_user ||= User.find(decoded_token[:id]) if id_found?
  rescue
    #Changing all the possible errors that are coming, and throws nil instead.
    nil
  end

  private
  # These methods are only going to be used within the application controller.
  def id_found?
    token && decoded_token && decoded_token[:id]
  end

  def decoded_token
    @decoded_token ||= Auth.decode(token) if token
    # checks the lib/auth.rb file
  end

  def token
    @token ||= if request.headers['Authorization'].present?
      request.headers['Authorization'].split.last
    end
  end
end
