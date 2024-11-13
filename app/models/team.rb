class Team < ApplicationRecord
  has_and_belongs_to_many :players, dependent: :destroy
  belongs_to :captain, class_name: 'Player'
  belongs_to :match
end
