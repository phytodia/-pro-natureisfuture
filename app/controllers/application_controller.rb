class ApplicationController < ActionController::Base
  #before_action :authenticate_user!
  around_action :switch_locale
  before_action :set_products_nav

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def after_sign_in_path_for(resource)
    if params.has_key?("customer")
      return espace_pro_path(current_customer)
    elsif params.has_key?("user")
      return admin_index_path
    elsif params.has_key?("commercial")
      return crm_path(current_commercial)
    end
  end

  def set_products_nav
    @pdts_nav_visage = Product.where(gamme:"visage")
    @pdts_nav_corps = Product.where(gamme:"corps")
    fail
  end

end
