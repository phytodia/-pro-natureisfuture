class ProductsController < ApplicationController

  def index
    @products = Product.all
  end

  def show
    @product = Product.find(params[:id])
    @actifs =  YAML.load_file("#{Rails.root.to_s}/db/yaml/actifs.yml")
    actifs_pdt = {}
    @photos = @product.photos
    #@photos_desktop = @photos + @photos + @photos + @photos
    #@photos_desktop = @photos.each_slice(3).to_a

    @labels = {
      "ECOCERT": "ecocert-organic.png",
      "Qualité Nature is Future": "charte-qualite.png",
      "FABRIQUÉ EN FRANCE": "fabrique-en-france.png",
      "NATUREL": "naturel.png",
      "PHYTOTHÉRAPIE INNOVANTE": "phytotherapie-innovante-responsable.png"
    }

    @yukacolor = 'green'
    case @product.yuka_appreciation
    when "Excellent"
      @yukacolor = "green"
    when "Bon"
      @yukacolor = "#94C52B"
    when "Médiocre"
      @yukacolor = "orange"
    when "Mauvais"
      @yukacolor = "red"
    end

  end

  def new
    @product = Product.new
    @actifs =  YAML.load_file("#{Rails.root.to_s}/db/yaml/actifs.yml").keys
  end

  def create
    @product = Product.new(product_params)
    @product.actions_product.delete_if(&:blank?)
    @product.labels.delete_if(&:blank?)
    @product.types_peau.delete_if(&:blank?)
    @product.ingredients.delete_if(&:blank?)
    @product.product_actifs.delete_if(&:blank?)
    @product.types_produit.delete_if(&:blank?)
    @product.preoccupations.delete_if(&:blank?)
    @product.save
    redirect_to products_path
  end

  def edit
    @product = Product.find(params[:id])
    @actifs =  YAML.load_file("#{Rails.root.to_s}/db/yaml/actifs.yml").keys
  end

  def update
    @product = Product.find(params[:id])
    @product.update(product_params)
    @product.actions_product.delete_if(&:blank?)
    @product.labels.delete_if(&:blank?)
    @product.types_peau.delete_if(&:blank?)
    @product.ingredients.delete_if(&:blank?)
    @product.product_actifs.delete_if(&:blank?)
    @product.types_produit.delete_if(&:blank?)
    @product.preoccupations.delete_if(&:blank?)
    @product.save
    redirect_to product_path(@product)
  end

  def categories
      @category = params[:category]
      fail
      @products = Product.all.where(gamme:@category)
  end
  def filtres
      @category = params[:filtrage][:category]
      x = params[:filtrage].as_json
      keys = []
      x.each { |key,value| keys.push(key) if value == 'positive' }
      #@products = Product.all.where(gamme:@category).where()
      @products = Product.where(gamme: "visage").where("'crème' = ANY (types_produit)")
      redirect_to cosmetique_category_path(:pdts => @products)
  end

  def destroy
  end

  def delete_photo
    product = Product.find(params[:product])
    #photo_to_delete = product.photos.where(id:params[:photo])
    product.photos.where(id:params[:photo]).purge
    redirect_to edit_product_path(product)
  end
  private

  def product_params
    params.require(:product).permit(:name,:description,:price_ht,:texture,:gamme,:utilisation,:contenance_revente,:contenance_cabine,:yuka_appreciation,:product_plus,:product_conseil,:product_gestes,:ingredients, product_actifs: [], actions_product: [], labels:[], types_peau:[], types_produit:[],preoccupations:[],photos: [])
  end
end
