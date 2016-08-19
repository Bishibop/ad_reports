require 'adwords_api'

class ApiPermissionsController < ApplicationController

  before_action :authenticate
  before_action do
    authorized_for :admin, :customer
  end

  def index
    if @current_user.admin?
      @customer = Customer.find(params[:customer_id])
      @adwords_initiate_url = customer_adwords_initiate_url(@customer)
      @bingads_initiate_url = ENV['BING_API_GRANT_URL'] + '/admin/' + @customer.id.to_s
    else
      @customer = @current_user.customer
      @adwords_initiate_url = adwords_initiate_url
      @bingads_initiate_url = ENV['BING_API_GRANT_URL'] + '/' + @customer.id.to_s
    end

  end

  def adwords_initiate

    session[:adwords_registration_customer_id] = params[:customer_id] if @current_user.admin?

    # This is totally the wrong way to get the oauth_url.
    # With Bing, there was just a method you used to explicitly request that
    # url. I should try and find that...Fuck Google's docs. What a joke.
    begin
      generate_adwords_authenticator.authorize({:oauth2_callback => adwords_callback_url})
    rescue AdsCommon::Errors::OAuth2VerificationRequired => e
      redirect_to e.oauth_url.to_s
    end
  end

  def adwords_callback

    if @current_user.admin?
      @customer = Customer.find(session[:adwords_registration_customer_id])
      session[:adwords_registration_customer_id] = nil
      redirect_path = customer_api_permissions_path(@customer)
    else
      @customer = @current_user.customer
      redirect_path = api_permissions_path
    end

    tokens = generate_adwords_authenticator.authorize({
      :oauth2_callback => adwords_callback_url,
      :oauth2_verification_code => params[:code]
    })

    @customer.update({
      adwords_access_token: tokens[:access_token],
      adwords_refresh_token: tokens[:refresh_token],
      adwords_issued_at: tokens[:issued_at],
      adwords_expires_in_seconds: tokens[:expires_in]
    })

    redirect_to redirect_path
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
