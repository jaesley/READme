class Follow < ApplicationRecord
  belongs_to :author
  belongs_to :user
  
  validates :author, presence: true, uniqueness: {:scope => :user, 
    message: "User is already following author." }
end
