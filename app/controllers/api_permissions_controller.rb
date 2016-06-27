require 'adwords_api'

class ApiPermissionsController < ApplicationController
  before_action do
    must_be :admin, :customer
  end

  def index
    if @current_user.is_admin?
      @customer = Customer.find(params[:customer_id])
    else
      @customer = @current_user.customer
    end

    @bing_ads_register_url = ENV['BING_API_GRANT_URL'] + '/' + @customer.id.to_s
  end

  def adwords_initiate

    if @current_user.is_admin?
      callback_url = customer_adwords_callback_url(params[:customer_id])
    else
      callback_url = adwords_callback_url
    end

    # This is totally the wrong way to get the oauth_url.
    # With Bing, there was just a method you used to explicitly request that
    # url. I should try and find that...Fuck Google's docs. What a joke.
    begin
      generate_adwords_authenticator.authorize({:oauth2_callback => callback_url})
    rescue AdsCommon::Errors::OAuth2VerificationRequired => e
      redirect_to e.oauth_url.to_s
    end
  end

  def adwords_callback

    if @current_user.is_admin?
      @customer = Customer.find(params[:customer_id])
    else
      @customer = @current_user.customer
    end

    token = generate_adwords_authenticator.authorize({
      :oauth2_callback => adwords_callback_url,
      :oauth2_verification_code => params[:code]
    })

    @customer.update({
      adwords_access_token: token[:access_token],
      adwords_refresh_token: token[:refresh_token],
      adwords_issued_at: token[:issued_at],
      adwords_expires_in_seconds: token[:expires_in]
    })

    redirect_to api_permissions_path
  end

  private

  def generate_adwords_authenticator
    AdwordsApi::Api.new({
      :authentication => {
          :method => 'OAuth2',
          :oauth2_client_id => ENV['ADWORDS_CLIENT_ID'],
          :oauth2_client_secret => ENV['ADWORDS_CLIENT_SECRET'],
          :oauth2_access_type => 'offline',
          :developer_token => ENV['ADWORDS_DEVELOPER_TOKEN'],
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
