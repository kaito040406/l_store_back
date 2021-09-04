# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_one :token, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :push_users, dependent: :destroy
  has_many :l_groups, dependent: :destroy

  attr_encrypted :credit_id, key: 'This is a key that is 191 bits!!'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  after_create :send_mail

  def send_mail
    UserMailer.registration_confirmation(self).deliver
  end
end
