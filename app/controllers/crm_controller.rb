class CrmController < ApplicationController
  layout "crm"
  #devise_group :crm, contains: [:user,:commercial]
  before_action :authenticate_commercial!
  #before_action :authenticate_crm!
  def index
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def crm_prospects
    @prospects = Prospect.all.where(commercial_id: current_commercial.id)
  end

  def show_prospect
    @prospect = Prospect.find(params[:id])
    @prospect_coord = Geocoder.search(@prospect.full_address).first.coordinates

    @instituts = Institut.all

    # The `geocoded` scope filters only flats with coordinates
    #url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    #base_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"

    #params = {
    #  location: '48.0777517,7.3579641',
    #  radius: 1500,
    #  type: 'beauty_salon',  # Vous pouvez ajuster le type en fonction de vos besoins
    #  key: 'AIzaSyC74ObwjB-HWFHBjvCyZUpgduKw-uQQ7a4'
    #}
    #response = HTTParty.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@inst_coord[0]},#{@inst_coord[1]}&radius=15000&type=beauty_salon&key=AIzaSyC74ObwjB-HWFHBjvCyZUpgduKw-uQQ7a4")

    #@results = response.parsed_response['results']

    def get_places_results(url, params)
      results = []

      loop do
        response = HTTParty.get(url, query: params)
        data = response.parsed_response

        # Vérifiez si la requête a réussi
        if response.code == 200
          results.concat(data.fetch('results', []))

          # Vérifiez s'il y a une page suivante
          if data.key?('next_page_token')
            # Attendez quelques secondes pour que la page suivante soit disponible
            sleep(2)

            # Utilisez le token de page pour obtenir les résultats de la page suivante
            params[:pagetoken] = data['next_page_token']
          else
            # Pas de page suivante, sortie de la boucle
            break
          end
        else
          puts "Erreur de requête: #{response.code}"
          puts response.body
          break
        end
      end

      results
    end

    base_url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"

    # Définissez vos paramètres communs

    params = {
      location: @prospect_coord.compact.join(', '),
      radius: 10000,
      type: 'beauty_salon',
      key: 'AIzaSyC74ObwjB-HWFHBjvCyZUpgduKw-uQQ7a4'
    }

    # Obtenez les résultats pour toutes les pages
    @all_results = get_places_results(base_url, params)

    # Traitez les résultats
    @all_results.each do |place|
      puts "#{place['name']} - #{place['vicinity']}"
    end


    @markers_conc = @all_results

    @markers = @markers_conc.map do |flat|
      {
        lat: flat["geometry"]["location"]["lat"],
        lng: flat["geometry"]["location"]["lng"],
        info_window_html: render_to_string(partial: "info_window"),
        marker_html: render_to_string(partial: "marker")
      }
    end
  end

  def new_prospect
    @prospect = Prospect.new
  end

  def edit_prospect
    @prospect = Prospect.find(params[:id])
  end
  def update_prospect
    @prospect = Prospect.find(params[:id])
    @prospect.update(prospect_params)
    # No need for app/views/restaurants/update.html.erb
    redirect_to prospects_crm_index_path
  end

  def crm_customers
    @commercial = current_commercial
    @clients = Customer.all.where(commercial_id: @commercial.id)
  end

  def new_customer
    @prospect = Prospect.find(params[:prospect])
    @customer = Customer.new
  end

  def create_customer
    @customer = Customer.new(customer_params)
    Prospect.find(@customer.prospect_id).update!(statut:"client")
    if @customer.save
        redirect_to prospects_crm_index_path, notice: "Le prospect a été correctement transformé en client"
    else
      render :new
    end
  end

  def show_customer
    @customer =  Customer.find(params[:id])
    @instituts = @customer.instituts
  end

  def new_institut
    @institut = Institut.new
    @regions =  YAML.load_file("#{Rails.root.to_s}/db/yaml/regions.yml")["France"].sort
    @institut.horaires = { lundi: {am_1:"",am_2:"",pm_1:"",pm_2:""},mardi: {am_1:"",am_2:"",pm_1:"",pm_2:""},mercredi: {am_1:"",am_2:"",pm_1:"",pm_2:""},jeudi: {am_1:"",am_2:"",pm_1:"",pm_2:""},vendredi: {am_1:"",am_2:"",pm_1:"",pm_2:""},samedi: {am_1:"",am_2:"",pm_1:"",pm_2:""},dimanche: {am_1:"",am_2:"",pm_1:"",pm_2:""}}
    @days = [:lundi, :mardi,:mercredi,:jeudi,:vendredi,:samedi,:dimanche]
  end

  def create_institut
    @institut = Institut.new(institut_params)
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

    @institut.horaires = my_hash

    if @institut.save
      redirect_to customer_crm_index_path(@institut.customer_id), notice: "L'établissement a été correctement crée"
    else
      render :new
    end
  end

  def edit_institut
    @institut = Institut.find(params[:id])
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

    #@institut = Institut.find(params[:institut][:institut_id])

    #@institut.customer_id = Institut.find(params[:institut][:institut_id]).customer_id

    #@institut.horaires = my_hash

    @institut = Institut.find(params[:institut][:institut_id])
    @institut.update(institut_params)
    @institut.customer_id = Institut.find(params[:institut][:institut_id]).customer_id
    @institut.update(horaires:my_hash)



    if @institut.save
      redirect_to crm_index_path(current_commercial), notice: "Update ok"
    else
      redirect_to edit_institut_crm_index_path , alert: "L'établissement n'a pas été mis à jour"
    end
    # No need for app/views/restaurants/update.html.erb

  end


  def destroy
  end

  private
  def prospect_params
    params.require(:prospect).permit(:lastname,:firstname,:email,:source,:institut,:cp,:country,:town,:tel,:date_prospect,:statut,:commercial_id,:comment)
  end

  def customer_params
    params.require(:customer).permit(:email, :password,:lastname,:firstname,:institut,:cp,:country,:town,:tel,:commercial_id,:prospect_id)
  end

  def institut_params
    params.require(:institut).permit(:name,:tel,:address,:cp,:city,:country,:latitude,:longitude,:category,:fb,:ig,:tik_tok,:rdv,:mess_promo,:region,:customer_id,horaires:{},photos: [])
  end
end
