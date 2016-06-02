# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application

# Makes the CLI command Heroku Local print logs in realtime (as opposed to
# buffering them)
$stdout.sync = true
