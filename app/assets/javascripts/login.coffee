
clientID = Icarus.AUTH0_CLIENT_ID
domain = Icarus.AUTH0_DOMAIN

lock = new Auth0LockPasswordless(clientID, domain)

lock.magiclink(
  callbackURL: Icarus.AUTH0_CALLBACK_PROTOCOL + '://' + Icarus.HTTP_HOST + Icarus.AUTH0_CALLBACK_PATH
  authParams:
    scope: 'openid email'
  closable: false
  primaryColor: "#00AEEF"
  icon: Icarus.logo_asset_path
  gravatar: false
  dict:
    title: "Reporting Dashboard Login"
    email:
      headerText: "Enter your email address below, and we will send you a link to sign into your dashboard."
    emailSent:
      success: "We've emailed you a link to sign into your dashboard. Check your inbox at {email} to find it."
)
