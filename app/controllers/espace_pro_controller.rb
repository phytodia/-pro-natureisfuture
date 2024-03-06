class EspaceProController < ApplicationController
  before_action :authenticate_customer!, except:[:index]

  include OrdersHelper

  def index
    if !current_customer.nil?
      redirect_to espace_pro_path(current_customer)
    end
  end

  def show
    @avantages = ["O%","-10%","-15%","-25%"]
    @last_palier = 4000
    @orders = Order.where(customer_id:current_customer)
    t = current_customer.total_trimestre.to_f / 4000
    #fail
    #t = t.floor(1)
    t = t * 3 # array des avantages - 1
    @index_avantage = (t).to_i
    trimestre(Date.today)
    if trimestre(Date.today)[:index] == 0
      year = Date.today.year - 1
      fail
      orders_year = current_customer.orders.where("EXTRACT(year FROM custom_date) = ?", year)
    else
      orders_year = current_customer.orders.where("EXTRACT(year FROM custom_date) = ?", year)
    end
  end

  def etablissements
    @instituts = Institut.all.where(customer_id: current_customer.id)
  end

  def institut_show
    @institut = Institut.friendly.find(params[:id])
    @current_customer = current_customer
    @carte_nif = @institut.carte.carte_soins.where.not(soin_id: nil).where.not(estimated_time:"") if !@institut.carte.nil?
    @carte_custom = @institut.carte.custom_soins if !@institut.carte.nil?
    @carte = @institut.carte

    if @institut.customer != @current_customer
      redirect_to espace_pro_path(current_customer)
    end
  end

  def edit_institut
    @institut = Institut.friendly.find(params[:id])
    @regions =  YAML.load_file("#{Rails.root.to_s}/db/yaml/regions.yml")["France"].sort
  end

  def update_institut
    x = institut_params[:horaires].to_hash.to_a.each_slice(4).to_a
    days = ["lundi","mardi","mercredi","jeudi","vendredi","samedi","dimanche"]
    my_hash = {}
    days.each_with_index do |day, index|
      my_hash[day] = {am_1:"",am_2:"",pm_1:"",pm_2:""}
      my_hash[day][:am_1] = x[index][0][1]
      my_hash[day][:am_2] = x[index][1][1]
      my_hash[day][:pm_1] = x[index][2][1]
      my_hash[day][:pm_2] = x[index][3][1]
    end

    @institut = Institut.find(params[:institut][:institut_id])
    @institut.update(institut_params)
    @institut.customer_id = Institut.find(params[:institut][:institut_id]).customer_id
    @institut.update(horaires:my_hash)

    if @institut.save
      redirect_to institut_espace_pro_index_path(@institut), notice: "L'institut a pas été mis à jour"
    else
      redirect_to edit_institut_path , alert: "L'institut n'a pas été mis à jour"
    end
  end

  def produits

  end

  def cours
  end
  def faq

  end
  def phototheque

  end
  def delete_photo
    institut = Institut.find(params[:institut])
    #photo_to_delete = product.photos.where(id:params[:photo])
    institut.photos.where(id:params[:photo]).purge
    redirect_to edit_institut_espace_pro_index_path(institut)
  end

  private
  def check_profile
    @profile = Profile.find(current_customer.profile.id)
    #redirect_to espace_pro_index_path
  end

  def institut_params
    params.require(:institut).permit(:name,:description,:tel,:address,:cp,:city,:country,:latitude,:longitude,:category,:fb,:ig,:tik_tok,:rdv,:mess_promo,:region,:customer_id,horaires:{},photos: [])
  end

end
