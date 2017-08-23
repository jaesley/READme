class Book < ApplicationRecord
  belongs_to :author
  has_many :follows, through: :author
  has_many :followers, through: :follows, source: :user

  validates :title, :goodreads_id, :author_id, :publication_date, presence: true
  validates :goodreads_id, uniqueness: true
end
