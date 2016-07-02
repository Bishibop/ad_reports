class Report < ActiveRecord::Base
  belongs_to :client

  validates :date, uniqueness: true
  validates :source, inclusion: {
    in: ['adwords', 'bing'],
    message: "%{value} must be 'adwords' or 'bing'."
  }
end
