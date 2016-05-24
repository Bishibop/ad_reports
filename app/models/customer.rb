class Customer < ActiveRecord::Base
  has_many :clients
end
