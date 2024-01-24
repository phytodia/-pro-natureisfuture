class CustomSoin < ApplicationRecord
  belongs_to :customer

  has_many :product_custom_soin_items, dependent: :destroy
  has_many :products, through: :product_custom_soin_items
  has_many :cartes, through: :carte_soins
  monetize :price_ttc_cents
end
