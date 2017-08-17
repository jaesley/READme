class Book < ApplicationRecord
  belongs_to :author
  has_many :follows, through: :author
  has_many :followers, through: :follows, source: :user
end
