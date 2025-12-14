class PickedPlayer < ApplicationRecord
  belongs_to :user, optional: true

  before_update :check_if_player_can_be_released
  after_update :check_user_available_price

  private 

  def check_if_player_can_be_released
    if (self.updated_at.present? && self.updated_at > 4.hours.ago) || (self.user_id_was.present? && self.user_id.nil?)
      errors.add(:base, "Player cannot be released within 4 hours of being picked.")
      throw(:abort)
    end
  end

  def check_user_available_price
    if self.user.present?
      user_picked_players = PickedPlayer.where(user_id: self.user.id)

      if self.released_time.present? && self.released_time > Time.current
        errors.add(:base, "Player cannot be picked before release time.")
        raise ActiveRecord::RecordInvalid.new(self)
      end
      
      if user_picked_players.count > 25
        errors.add(:base, "You can pick a maximum of 25 players.")
        raise ActiveRecord::RecordInvalid.new(self)
      end

      total_price = user_picked_players.sum(:buy_price)
      if total_price > 1750
        errors.add(:base, "Total price of picked players exceeds the limit of 1750.")
        raise ActiveRecord::RecordInvalid.new(self)
      end
    end
  end

end
