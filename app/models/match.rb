class Match < ApplicationRecord
  belongs_to :tournament
  belongs_to :winner_team, class_name: 'Team', optional: true # Winner team reference
  has_many :teams, dependent: :destroy
  has_many :performances, dependent: :destroy
  
end
