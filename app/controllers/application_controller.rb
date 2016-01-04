class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include Authenticable

  before_filter :reload_rails_admin, if: :rails_admin_path?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.destroy_user_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    '/admin'
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  private

    def reload_rails_admin
      models = %W(User Node Cisco Zte Dlink Location Customer Comment Port)
      models.each do |m|
        RailsAdmin::Config.reset_model(m)
      end
      RailsAdmin::Config::Actions.reset

      load("#{Rails.root}/config/initializers/rails_admin.rb")
    end

    def rails_admin_path?
      controller_path =~ /rails_admin/ && Rails.env.development?
    end


end
