class Customer < ActiveRecord::Base
  has_many :clients
  validates :name, presence: true,
                    length: { minimum: 5 }
end
