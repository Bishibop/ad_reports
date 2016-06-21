class ApiPermissionsController < ApplicationController
  def index
    # This need to be the customer from the users session
    # But we're not doing that because I only have one customer!
    @customer = Customer.all.first
    if Rails.env.production?
      @bing_ads_register_url = "https://ad-reports-bing.herokuapp.com/#{@customer.id}"
    else
      @bing_ads_register_url = "https://ad-reports-bing-staging.herokuapp.com/#{@customer.id}"
    end
  end
end
