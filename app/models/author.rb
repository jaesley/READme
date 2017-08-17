class Author < ApplicationRecord
  has_many :follows
  has_many :followers, through: :follows, source: :user
  has_many :books
end
