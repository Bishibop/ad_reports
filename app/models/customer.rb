class Customer < ActiveRecord::Base
  has_many :clients, dependent: :destroy
  validates :name, presence: true,
                    length: { minimum: 5 }
end
