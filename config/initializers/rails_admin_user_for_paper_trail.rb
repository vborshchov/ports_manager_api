RailsAdmin::ApplicationController.module_eval do
  def user_for_paper_trail
    _current_user && _current_user.email
  end
end