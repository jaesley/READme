require 'pp'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :validatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :omniauthable, :omniauth_providers => [:goodreads]

  has_many :follows
  has_many :authors, through: :follows
  has_many :books, through: :authors

  def self.from_omniauth(auth)
     pp auth
     where(provider: auth.provider, uid: auth.uid.to_s).first_or_create do |user|
      #  p user
       p "*" * 1000
       user.provider = auth.provider
       user.uid = auth.uid
       user.user_name = auth.info.user_name
       user.password = Devise.friendly_token[0,20]
       user.save
     end
   end

   def email_changed?
     false
   end
end
