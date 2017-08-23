class Follow < ApplicationRecord
  belongs_to :author
  belongs_to :user

  validates :user_id, :author_id, presence: tru
  validates :author_id, uniqueness: { scope: :user }
end
