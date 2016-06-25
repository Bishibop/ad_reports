class Client < ActiveRecord::Base
  belongs_to :customer
  validates :name, presence: true, length: { minimum: 5 }
  validates :login_domain, presence: true, format: { without: /\s/ }
end
