class Customer < ActiveRecord::Base
  has_many :clients, dependent: :destroy
  validates :name, presence: true, length: { minimum: 5 }
  validates :login_domain, presence: true, format: { without: /\s/ }
  after_commit do
    UpdateAuth0LoginDomains.new.call
  end
end
