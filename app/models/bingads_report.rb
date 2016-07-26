class BingadsReport < ActiveRecord::Base
  belongs_to :client

  validates :date, uniqueness: true
  validates :date, presence: true

  METRIC_NAMES = [ :cost,
                   :impressions,
                   :click_through_rate,
                   :clicks,
                   :form_conversions,
                   :conversion_rate,
                   :average_cost_per_click,
                   :average_position ]

  def self.metric_names
    METRIC_NAMES
  end
end
