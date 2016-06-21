class ApiPermissionsController < ApplicationController
  def index
    # This need to be the customer from the users session
    # But we're not doing that because I only have one customer!
    @customer = Customer.all.first
    @bing_ads_register_url = ENV['BING_API_GRANT_URL'] + '/' + @customer.id.to_s
  end
end
