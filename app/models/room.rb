class Room < ApplicationRecord
  belongs_to :user

  before_create :create_unique_code
  after_create :self_join_room


  private 

  def create_unique_code
    self.start_date = Time.current
    self.end_date = Time.current + 7.days
    self.code = loop do
      random_code = SecureRandom.random_number(900_000) + 100_000
      break random_code unless Room.exists?(code: random_code)
    end
  end

  def self_join_room
    user.update(room_id: self.id)
  end


end
