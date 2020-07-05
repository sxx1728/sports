class ApplicationController < ActionController::Base
  before_action :authenticate_admin!

  alias current_user current_admin

end
