class Room < ApplicationRecord
  belongs_to :user
  has_many :picked_players, dependent: :destroy

  before_create :create_unique_code
  after_create :self_join_room
  after_create :add_players_to_room


  private 

  def create_unique_code
    self.start_date = Time.zone.now.beginning_of_day
    self.end_date   = Time.zone.now.beginning_of_day + 7.days - 1.second
    self.code = loop do
      random_code = SecureRandom.random_number(900_000) + 100_000
      break random_code unless Room.exists?(code: random_code)
    end
  end

  def self_join_room
    user.update(room_id: self.id)
  end

  # def add_players_to_room
  #   # from below file pick 200 players list as random.
  #   # auction_players = File.open "public/auction/players.json"
  #   # @auction_players = JSON.load auction_players

  #   # sample player json - { "id": 1, "name": "Sachin Tendulkar", "age": 51, "playertype": "Batting", "photo_url": "", "country_code": "IN", "t20_point": 65, "odi_point": 100, "price": 95 },
    
  #   # PickedPlayer.new <PickedPlayer:0x0000000108e52578 id: nil, team_type: nil, buy_price: nil, player_id: nil, user_id: nil, created_at: nil, updated_at: nil, release_time: nil>
  #   # for each id create picked_player with player_id as id, buy_price as price and release_time also. 

  #   # room has start_date and end_date. end_date = start_date + 3.days. release time should be between these 2 time. release time should be between 9 am to 9 pm. And in a 30 minute gap. like 9.00 9.30 10.00 ...
  #   # so each 2 day 12 hour X 3 times = 36 times players will be released. means 72 times players will be released.
  #   # so 200 players will be released within 72 times.
  #   # remember max 4, and min 1 players can be released together.

  
  # end



  def add_players_to_room
    file_path = Rails.root.join("public/auction/players.json")
    players = JSON.parse(File.read(file_path))
    selected_players = players.sample(220)

    release_slots = generate_release_slots

    max_assignable = [selected_players.size, release_slots.size].min

    selected_players.first(max_assignable).each_with_index do |player, index|
      PickedPlayer.create!(
        room_id: self.id,
        player_id: player["id"],
        buy_price: player["price"],
        release_time: release_slots[index]
      )
    end
  end


  def generate_release_slots
    slots = []

    current_date = start_date.in_time_zone.to_date
    last_date    = (end_date - 2.days).in_time_zone.to_date

    while current_date <= last_date
      day_start = Time.zone.local( current_date.year, current_date.month, current_date.day, 10, 0, 0)
      day_end = Time.zone.local( current_date.year, current_date.month, current_date.day, 22, 0, 0)

      current_time = day_start

      while current_time <= day_end
        if current_time >= start_date && current_time <= end_date
          slots << current_time
        end
        current_time += 30.minutes
      end
      current_date += 1.day
    end

    slots.shuffle
  end



end


