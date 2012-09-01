# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'open-uri'
require 'json'
require 'hpricot'
require "httparty"
require 'calendar_date_select'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem # logged_in? and current_user
  include ApplicationHelper
#  include SslRequirement

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8ba6dfd39c1469ef1d044a318d51b7bf'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  def check_login
    if logged_in?
      if current_user.is_verified == false
        if current_user.biz?
          flash[:notice] = "For security reasons, please verify your email address before you continue"
        else
          flash[:notice] = "Agree to Terms and Conditions to Proceed"
        end
        redirect_to root_path
      end
    else
      flash[:notice] = "Please login first"
      redirect_to root_path
    end
  end

  def check_emails(emails)
    return false if emails.blank?
    return false if emails.gsub(',','').blank?
    emails.split(',').each do |email|
        unless email.strip =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/
          return false
        end
    end
    return true
  end

   
end
