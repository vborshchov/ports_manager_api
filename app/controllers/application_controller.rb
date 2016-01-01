class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include Authenticable

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.destroy_user_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    '/admin'
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

end
