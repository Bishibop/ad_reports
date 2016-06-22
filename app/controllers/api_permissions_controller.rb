require 'adwords_api'

class ApiPermissionsController < ApplicationController
  def index
    # This need to be the customer from the users session
    # But we're not doing that because I only have one customer!
    @customer = Customer.all.first
    @bing_ads_register_url = ENV['BING_API_GRANT_URL'] + '/' + @customer.id.to_s

    # This feels like the wrong way to get the oauth_url
    # With Bing, there was just a method you used to explicitly request that
    # url. I should try and find that...Fuck Google's docs. What a joke.
    begin
      generate_adwords_authenticator.authorize({:oauth2_callback => adwords_callback_url})
    rescue AdsCommon::Errors::OAuth2VerificationRequired => e
      @adwords_register_url = e.oauth_url.to_s
    end
  end

  #def adwords_initiate
    #generate_adwords_authenticator.authorize({:oauth2_callback => adwords_callback_url})
  #end

  def adwords_callback
    token = generate_adwords_authenticator.authorize(
      {
        :oauth2_callback => adwords_callback_url,
        :oauth2_verification_code => params[:code]
      }
    )
    puts "TOKEN INCOMING"
    puts token.inspect
  end

  private

  def generate_adwords_authenticator
    AdwordsApi::Api.new({
      :authentication => {
          :method => 'OAuth2',
          :oauth2_client_id => ENV['ADWORDS_CLIENT_ID'],
          :oauth2_client_secret => ENV['ADWORDS_CLIENT_SECRET'],
          :oauth2_access_type => 'offline',
          :developer_token => 'WxKuWXEK11iPJE3JN5PL3Q',
          :user_agent => 'Icarus Reporting'
      },
      :service => {
        :environment => 'PRODUCTION'
      },
      :connection => {
        :enable_gzip => false
      },
      :library => {
        :log_level => 'DEBUG'
      }
    })
  end
end
