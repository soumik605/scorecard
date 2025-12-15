class PickedPlayer < ApplicationRecord
  self.time_zone_aware_attributes = true
  self.time_zone_aware_types = [:datetime, :timestamp]
  
  belongs_to :user, optional: true

  before_update :check_if_player_can_be_released
  before_update :check_user_available_price
  after_update :update_user_totals, if: :saved_change_to_user_id?

  private 

  def check_if_player_can_be_released
    if (updated_at_changed? && updated_at > 4.hours.ago) || 
       (user_id_was.present? && user_id.nil?)
      errors.add(:base, "Player cannot be released within 4 hours of being picked.")
      throw(:abort)
    end
  end

  def check_user_available_price
    return unless user_id_was.nil? && user_id.present?

    user = User.find(user_id)
    
    if released_time.present? && released_time > Time.current.in_time_zone('Asia/Kolkata')
      errors.add(:base, "Player cannot be picked before release time.")
      throw(:abort)
    end
    
    user_picked_players = PickedPlayer.where(user_id: user.id).where.not(id: id)
    
    if user_picked_players.count >= 25
      errors.add(:base, "You can pick a maximum of 25 players.")
      throw(:abort)
    end

    total_price = user_picked_players.sum(:buy_price) + (buy_price || 0)
    if total_price > 1750
      errors.add(:base, "Total price of picked players exceeds the limit of 1750.")
      throw(:abort)
    end
  end

  def update_user_totals
    user.update_cached_totals if user.respond_to?(:update_cached_totals)
  end
end
