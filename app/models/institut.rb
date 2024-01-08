class Institut < ApplicationRecord
  belongs_to :customer
  geocoded_by :full_address
  after_validation :geocode, if: :will_save_change_to_address?

  def full_address
    [address, cp, city, country].compact.join(', ')
  end
end
