class PickedPlayer < ApplicationRecord
  belongs_to :user, optional: true
end
