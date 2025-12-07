class SendPlayersToRoomJob < ApplicationJob
  queue_as :default

  def perform(*args)
    room = Room.last
    picked_players = PickedPlayer.all
    if room.present? && room.start_date.present? && room.end_date.present? && picked_players.count < 100
      if DateTime.current.between?(room.start_date, room.end_date)
        picked_player_ids = PickedPlayer.pluck(:player_id)
        auction_players = File.open "public/auction/players.json"
        auction_players = JSON.load auction_players
        all_player_ids = auction_players.map { |player| player["id"] }
        pickable_player_ids = all_player_ids - picked_player_ids
        random_player_ids = pickable_player_ids.sample(2)
        random_player_ids.each do |player_id|
          plr = auction_players.find { |p| p["id"] == player_id }
          PickedPlayer.create(player_id: player_id, buy_price: plr["price"])
        end
      end
    end
  end
end
