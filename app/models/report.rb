class Report < ActiveRecord::Base
  belongs_to :client

  validates :date, uniqueness: true
  validates :source, inclusion: {
    in: ['adwords', 'bing'],
    message: "%{value} must be 'adwords' or 'bing'."
  }

  METRIC_NAMES = [ :cost,
                   :impressions,
                   :click_through_rate,
                   :clicks,
                   :all_conversions,
                   :all_conversion_rate,
                   :cost_per_all_conversion,
                   :conversions,
                   :conversion_rate,
                   :cost_per_conversion,
                   :average_cost_per_click,
                   :average_position ]

  def self.metric_names
    METRIC_NAMES
  end

end
