class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  protect_from_forgery with: :null_session # Disable CSRF protection for the entire app, normally i wouldn't do this...
end
