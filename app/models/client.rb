class Client < ActiveRecord::Base
  belongs_to :customer

  has_many :marchex_call_records, dependent: :destroy
  has_many :bingads_reports,  dependent: :destroy
  has_many :adwords_reports, dependent: :destroy do
    def top_ad_network_metrics(num, date_range)
      kcs, qcs = self.where(date: date_range)
                  .pluck(:keyword_conversions, :query_clicks)
                  .transpose
                  .map do |hash_set|
                    hash_set.inject do |memo, hsh|
                      memo.merge!(hsh) { |key, oldval, newval| oldval.to_i + newval.to_i }
                    end
                      .inject({}) do |memo, pair|
                        # This sums over match types
                        key = pair[0][8..-1]
                        if memo[key]
                          memo[key] = memo[key] + pair[1].to_i
                        else
                          memo[key] = pair[1].to_i
                        end
                        memo
                      end
                      .sort_by { |key, value| value.to_i }
                      .last(num)
                      .reverse
                      .to_h
                  end
      { adwordsKeywordConversions: kcs, adwordsQueryClicks: qcs }
    end
  end

  validates :name, presence: true, length: { minimum: 5 }
  validates :login_domain, presence: true, format: { without: /\s/ }
  validates :adwords_cid, uniqueness: true, allow_nil: true
  validates :bing_ads_aid, uniqueness: true, allow_nil: true
  validates :marchex_account_id, uniqueness: true, allow_nil: true

end
