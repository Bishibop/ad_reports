class Client < ActiveRecord::Base
  belongs_to :customer
  has_many :adwords_reports, -> { order(date: :asc)}

  validates :name, presence: true, length: { minimum: 5 }
  validates :login_domain, presence: true, format: { without: /\s/ }
  validates :adwords_cid, uniqueness: true

end
