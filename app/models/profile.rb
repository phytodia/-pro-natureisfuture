class Profile < ApplicationRecord
  belongs_to :user, dependent: :destroy
  belongs_to :team_member, optional: true
end
