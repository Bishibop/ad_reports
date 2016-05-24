class Client < ActiveRecord::Base
  belongs_to :customer
  validates :name, presence: true,
                    length: { minimum: 5 }
end
