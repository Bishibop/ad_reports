class BingadsReport < ActiveRecord::Base
  belongs_to :client

  validates :date, uniqueness: true
  validates :date, presence: true
end
