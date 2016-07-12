class BingadsReport < ActiveRecord::Base
  belongs_to :client

  validates :date, uniqueness: true
end
