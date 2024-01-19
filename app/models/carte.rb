class Carte < ApplicationRecord
  belongs_to :institut
  has_many :carte_soins, dependent: :destroy
  has_many :soins, through: :carte_soins
  has_many :custom_soins, through: :carte_soins
  accepts_nested_attributes_for :carte_soins
end
