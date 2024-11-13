class Tournament < ApplicationRecord
  has_many :matches, dependent: :destroy
end
