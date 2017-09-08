class Author < ApplicationRecord
  has_many :follows
  has_many :followers, through: :follows, source: :user
  has_many :books

  validates :name, :goodreads_id, presence: true
  validates :goodreads_id, uniqueness: true
end
