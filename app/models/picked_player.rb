class PickedPlayer < ApplicationRecord
  belongs_to :user, optional: true

  after_update :check_user_available_price

  private 

  def check_user_available_price
    if self.user.present?
      user_picked_players = PickedPlayer.where(user_id: self.user.id)
      
      if user_picked_players.count > 11
        errors.add(:base, "You can pick a maximum of 11 players.")
        raise ActiveRecord::RecordInvalid.new(self)
      end
      PickedPlayer.where(user_id: self.user.id)
      total_price = user_picked_players.sum(:buy_price)
      if total_price > 850
        errors.add(:base, "Total price of picked players exceeds the limit of 850.")
        raise ActiveRecord::RecordInvalid.new(self)
      end
    end
  end


end
