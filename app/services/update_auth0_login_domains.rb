class UpdateAuth0LoginDomains

  def call
    admin_emails = ['nwmullen@gmail.com']

    customer_domain_id_map = Customer.all.inject({}) do |memo, customer|
      memo[customer.login_domain] = customer.id
      memo
    end

    client_domain_id_map = Client.all.inject({}) do |memo, client|
      memo[client.login_domain] = client.id
      memo
    end

    Auth0Client.new({
      :token => ENV['AUTH0_API_TOKEN'],
      :domain => ENV['AUTH0_DOMAIN'],
      :api_version => 2
    }).update_rule(ENV['AUTH0_LOGIN_DOMAINS_RULE_ID'], {
      "script": "function (user, context, callback) {\n  global.adminEmails = #{admin_emails.to_json};\n  global.customerDomainIdMap = #{customer_domain_id_map.to_json};\n  global.clientDomainIdMap = #{client_domain_id_map.to_json};\n\n  callback(null, user, context);\n}"
    })
  end
end
