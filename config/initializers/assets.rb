# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# This precompiles js so that I can load them on specific pages and after the page loads.
Rails.application.config.assets.precompile += %w(login.js dashboards.js)
# Following method is for if you need js and css
#%w( login, dashboards ).each do |controller|
  #Rails.application.config.assets.precompile += ["#{controller}.js",
#                                                 "#{controller}.css]
#end
