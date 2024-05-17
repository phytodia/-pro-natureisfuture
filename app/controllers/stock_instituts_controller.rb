class StockInstitutsController < ApplicationController
  layout "espace"
  def index
    @customer = current_customer
    @institut = @customer.instituts.last
    @stock = @institut.stock_institut
  end

  def edit
    @stock = StockInstitut.find(params[:id])
  end

  def update
    @stock =  StockInstitut.find(params[:stock_institut][:stock_id])
    params_items = params[:stock_institut][:pdt_stock_items_attributes]
    params_items.keys.each do |key|
      id_pdt_stock = params_items[key]["pdt_stock_item_id"].to_i
      new_qty = params_items[key]["quantity"].to_i
      @stock.pdt_stock_items.find(id_pdt_stock).update(quantity:new_qty)
    end
    redirect_to stock_instituts_path(@stock)
  end
end
