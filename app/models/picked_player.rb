class PickedPlayer < ApplicationRecord
  self.time_zone_aware_attributes = true
  self.time_zone_aware_types = [:datetime, :timestamp]
  
  belongs_to :user, optional: true

  before_update :check_if_player_can_be_released
  after_update :check_user_available_price
  validate :team_size_limit

  enum team_type: {
    odi: "odi",
    t20: "t20"
  }

  private 

  def check_if_player_can_be_released
    # if (self.user_id_was.present? && self.user_id.nil?)
    #   puts "ERROR: Player cannot be released within 4 hours of being picked."
    #   errors.add(:base, "Player cannot be released within 4 hours of being picked.")
    #   throw(:abort)
    # end
  end

  def check_user_available_price
    if self.user.present?
      user_picked_players = PickedPlayer.where(user_id: self.user.id)

      if self.release_time.present? && self.release_time > Time.current
        puts "ERROR: Player cannot be picked before release time."
        errors.add(:base, "Player cannot be picked before release time.")
        raise ActiveRecord::RecordInvalid.new(self)
      end
      
      if user_picked_players.count > 25
        puts "ERROR: You can pick a maximum of 25 players."
        errors.add(:base, "You can pick a maximum of 25 players.")
        raise ActiveRecord::RecordInvalid.new(self)
      end

      total_price = user_picked_players.sum(:buy_price)
      if total_price > 1550
        puts "ERROR: Total price of picked players exceeds the limit of 1550."
        errors.add(:base, "Total price of picked players exceeds the limit of 1550.")
        raise ActiveRecord::RecordInvalid.new(self)
      end
    end
  end

  def team_size_limit
    return if team_type.blank?
    
    user_players = nil
    user_players = PickedPlayer.where(user_id: self.user.id) if self.user.present?

    if user_players.present? && user_players.where(team_type: team_type).where.not(id: id).count >= 11
      errors.add(:team_type, "can have only 11 players")
    end
  end

end
