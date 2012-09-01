require 'csv'

class UsersController < ApplicationController
  before_filter :check_login, :except => [:biz, :login, :agree, :terms, :verify_user, :forgot, :destroy]

  def login
    if request.post?
        if !params[:user][:account_number].strip.blank?
            @feed = Feed.first(:conditions => ["account_number = ?", params[:user][:account_number]])
            @user = User.find_by_account_number(params[:user][:account_number])
        end
        if @feed
            if @user.nil?
                @user = User.new(:account_number => params[:user][:account_number])
                @user.save
            end
            self.current_user = @user
            if session[:return_to]
                code = session[:return_to].gsub("/", "").strip
                redirect_to paypal_path(code, session[code][0].to_i, session[code][1].to_i)
            else
                redirect_to root_path
            end
        else
#            @user.errors.add_to_base("Enter valid information")
            flash[:notice] = "Sorry, we cannot find your account. Please try again or dial 1-800-557-2117"
        end
    end
  end

  def agree
    if logged_in?
      if request.post?
        current_user.update_attribute(:is_verified, params[:agree])
        redirect_to root_path
      end
    else
      redirect_to root_path
    end
  end

  def verify
    if logged_in?
      @feed = current_user.feed_info
      if request.post?
        if params[:commit]
          if @feed.update_attributes(params[:feed])
            session[:skip_verify] = "continued"
            redirect_to root_path
          else
            flash[:notice] = "Enter valid information"
          end
        else
          session[:skip_verify] = "skip"
          redirect_to root_path
        end
      end
    else
      redirect_to root_path
    end
  end

  def negotiate
    @feed = current_user.feed_info
    @offer = @feed.offers.last(:conditions => "response IS NULL")
    @last_offer = false
    if request.post?
      submit = params[:submit_button]
      if submit
        if submit.strip.downcase == "accept"
          @counter_offer = @feed.offers.last(:conditions => ["response like (?) or response like (?)", "counter", "last"])
          for offer in @feed.offers.all(:conditions => "response IS NULL")
            offer.expire
          end
          @counter_offer.accept
          flash[:notice] = "You have accepted the offer"
          redirect_to root_path
          return
        elsif submit.strip.downcase == "decline"
          @counter_offer = @feed.offers.last(:conditions => ["response like (?) or response like (?)", "counter", "last"])
          for offer in @feed.offers.all(:conditions => "response IS NULL")
            offer.expire
          end
          @counter_offer.reject

#          @payment = Payment.new
#          @payment.offer = @counter_offer
#          @payment.amount = @counter_offer.amount
#          @payment.payment_type = "decline"
#          @payment.cc_no = generate_number(16)
#          @payment.name = "#{@counter_offer.feed.last_name.strip} #{@counter_offer.feed.first_name.strip}"
#          @payment.email = ""
#          @payment.save
          #flash[:notice] = "You have declined our final offer. An agent may call you to discuss options. Thank You"
          #redirect_to root_path
          Notification.deliver_decline_email(@feed.id)
          redirect_to logout_path
          return
        end
      end
      if params[:offer] and !params[:offer].strip.blank?
        amount = params[:offer].gsub(/\D+/, '')
        @last_offer = @feed.offers.last(:conditions => ["response IS NULL"])
        @counter_offers = @feed.offers.all(:conditions => ["response like (?)", "counter"])
        if @last_offer
          if amount.to_i <= @last_offer.amount
            flash[:notice] = "Your last offer was $#{@last_offer.amount.to_f.ceil}. Please make an offer higher than the last offer."
            redirect_to root_path
            return
          end
        end
        if @counter_offers.size > 0
          @counter_offer = @counter_offers.last
          round_limit = (@counter_offer.amount*0.05).ceil
          #counter_amount = (@counter_offer.amount.to_f.ceil - ((@feed.balance.to_f - (@feed.floor_limit.to_f*1.2))/3).to_f.ceil)
          counter_amount = (@counter_offer.amount.to_f.ceil - (rand(10)+ 5))
          #render :text => [round_limit, counter_amount].inspect and return false
          if((amount.to_f.ceil-@last_offer.amount) <= round_limit)
            flash[:notice] = "Please make an offer greater than $#{@last_offer.amount.ceil + round_limit.ceil}"
            redirect_to root_path
            return
          end
        end
        if amount.to_i < (@feed.floor_limit.to_f*0.60)
          flash[:notice] = "Please make an offer of at least $#{(@feed.floor_limit.to_f*0.60).ceil} to start negotiating"
          redirect_to root_path
          return
        else
          @offer = Offer.new
          @offer.feed = @feed
          @offer.amount = amount
          @offer.save
        end

        if((@offer.amount >= @feed.balance) or (@offer.amount >= (@feed.floor_limit.to_f*(1.5)).ceil))
          if @offer.amount >= @feed.balance
            @offer.change_amount(@feed.balance)
          end
          for offer in @feed.offers.all(:conditions => "response IS NULL")
            offer.expire
          end
          @offer.accept
          flash[:notice] = "Your offer is accepted"
          redirect_to root_path
        else
          if @counter_offers.size > 0 and @counter_offers.size < 100
            @counter_offer = @counter_offers.last
            if(@offer.amount > (@feed.floor_limit.to_f*1.2))
              for offer in @feed.offers.all(:conditions => "response IS NULL")
                offer.expire
              end
              @counter_offer.expire
              @offer.accept
              flash[:notice] = "Your offer is accepted"
              redirect_to root_path
            else
              round_limit = (@counter_offer.amount*0.05).ceil
              #counter_amount = (@counter_offer.amount.to_f.ceil - ((@feed.balance.to_f - (@feed.floor_limit.to_f*1.2))/3).to_f.ceil)
              counter_amount = (@counter_offer.amount.to_f.ceil - (rand(10) +  5 ))
              if((counter_amount - round_limit.ceil) <= ((@feed.floor_limit.to_f*1.2).ceil))
                @counter_offer = Offer.new
                @counter_offer.feed = @feed
                @counter_offer.amount = (@feed.floor_limit.to_f*1.2).ceil
                @counter_offer.response = "last"
                @counter_offer.save
                flash[:notice] = "Our Final offer is $#{@counter_offer.amount}"
              elsif(@offer.amount >= (counter_amount - round_limit.ceil))
                for offer in @feed.offers.all(:conditions => "response IS NULL")
                  offer.expire
                end
                @counter_offer.expire
                @offer.accept
                flash[:notice] = "Your offer is accepted"
                redirect_to root_path
              elsif((@offer.amount-@last_offer.amount) > round_limit)
                @counter_offer = Offer.new
                @counter_offer.feed = @feed
                @counter_offer.amount = counter_amount
                @counter_offer.response = ((@counter_offers.size == 2) ? "last" : "counter")
                @counter_offer.save
              else
                flash[:notice] = "Please make an offer greater than $#{@last_offer.amount.ceil + round_limit.ceil}"
                redirect_to root_path
              end
            end
          elsif @counter_offers.size == 100
            @counter_offer = Offer.new
            @counter_offer.feed = @feed
            @counter_offer.amount = (@feed.floor_limit.to_f*1.2).ceil
            @counter_offer.response = "last"
            @counter_offer.save
          else
            @counter_offer = Offer.new
            @counter_offer.feed = @feed
            #counter_amount = (@feed.balance.to_f.ceil - ((@feed.balance.to_f - (@feed.floor_limit.to_f*1.2))/3).to_f.ceil)
            counter_amount = (@feed.balance.to_f.ceil - (rand(10) + 5 ))
            if counter_amount > @feed.balance
              @counter_offer.amount = (@feed.balance.to_f*(0.95)).ceil
            else
              @counter_offer.amount = counter_amount
            end
            @counter_offer.response = "counter"
            @counter_offer.save
          end
        end
      else
        flash[:notice] = "Please make an offer"
        redirect_to root_path
      end
    else
      @counter_offer = @feed.offers.last(:conditions => ["response like (?)", "counter"])
    end
  end

  def schedule
    @accepted_offer = Offer.find_by_id(params[:id])
    if request.post?
     # @accepted_offer = Offer.find_by_id(params[:id])

#      if params[:commit]
#        if params[:commit].strip.downcase == "agent"
#          @payment = Payment.new
#          @payment.offer = @accepted_offer
#          @payment.amount = @accepted_offer.amount
#          @payment.payment_type = "agent"
#          @payment.cc_no = generate_number(16)
#          @payment.name = "#{@accepted_offer.feed.last_name.strip} #{@accepted_offer.feed.first_name.strip}"
#          @payment.email = ""
#          @payment.save
#          flash[:notice] = "An agent will call you shortly. Thank You"
#          redirect_to root_path
#          return
#        end
#      end
      if params[:pt]
       # if params[:pt].strip.downcase == "full"
          birthdate = "#{params[:year1]}-#{params[:month1]}-#{params[:day1]}"
          session[:payment_date] = birthdate.to_date
          redirect_to payment_path(params[:pt], @accepted_offer)
#        else
#          birthdate = "#{params[:year2]}-#{params[:month2]}-#{params[:day2]}"
#          session[:payment_date] = birthdate.to_date
#          redirect_to payment_path(params[:pt], @accepted_offer)
#        end
      end
    end
  end

  def payment
    @offer = Offer.find_by_id(params[:id])
    @pt = params[:pt]
    @amount = ((@pt == "monthly") ? (@offer.amount/@offer.feed.payment_term) : @offer.amount)
    if request.post?
      @payment = Payment.new(params[:payment])
      @payment.payment_date = session[:payment_date]
      @payment.offer = @offer
      if @payment.acc_type.strip.downcase != "bank"
        if check_emails(@payment.email) == false
          @payment.errors.add(:email, "^Hey, please enter valid email")
        end
        @month = @payment.cc_expiry_m
      else
        @payment.name = @payment.account_holders_name
      end
      if @payment.errors.empty? and @payment.valid?
        @payment.name = @payment.account_holders_name if @payment.acc_type.strip.downcase.eql? "bank"
        if @payment.save
        @user = @payment.offer.feed.user
        flash[:notice] = "Congratulations, Payment Scheduled"
        redirect_to root_path
        end
      else
        flash[:error] = "Please enter valid information"
      end
    end
  end

  def biz
    error = nil
    if logged_in?
      redirect_to root_path
      return
    end
    if params[:user]
        logout_keeping_session!
        @user = User.authenticate(params[:user][:email], params[:user][:password])
        if @user
          # Protects against session fixation attacks, causes request forgery
          # protection if user resubmits an earlier form using back
          # button. Uncomment if you understand the tradeoffs.
          # reset_session
          self.current_user = @user
          new_cookie_flag = (params[:remember_me] == "1")
          handle_remember_cookie! new_cookie_flag
          if @user.is_verified == false
            flash[:notice] = "For security reasons, please verify your email address before you continue"
          end
          redirect_back_or_default('/')
          #flash[:notice] = "Logged in successfully"
        else
          #note_failed_signin
          @user = User.new(params[:user])
          if @user.email.blank?
              error = "<span>Email can't be blank</span>"
              if @user.password.blank?
                  error += "<br /><span>Password can't be blank</span>"
              end
          elsif @user.password.blank?
              error = "<span>Password can't be blank</span>"
          elsif !check_emails(params[:user][:email])
              error = "<span>Email should look like an email</span>"
          end
          if !params[:user][:email].nil? and !params[:user][:email].blank?
              user = User.find_by_email(params[:user][:email])
              if user
                  error = "<span>Incorrect email/password combination</span>"
              end
          end
          success = error.nil? && @user && @user.save
          if success && @user.errors.empty?
            self.current_user = @user
            flash[:notice] = "For security reasons, please verify your email address before you continue"
            redirect_back_or_default('/')
            Notification.deliver_signup_notification(@user)
          else
            flash[:error] = "Please enter valid information"
            @user.errors.add_to_base(error)
          end
        end
    end
  end

  def profile
    if current_user.profile
      @user_profile = current_user.profile
    end

    if request.post?
        @user_profile = Profile.new(params[:user_profile])
        @profile = Profile.new(params[:user_profile])
        @profile.user = current_user

        if @profile.valid? and @profile.errors.empty?
          if current_user.profile
            current_user.profile.update_attributes(params[:user_profile])
            flash[:notice] = "Profile Updated!"
          else
            @profile.save
            flash[:notice] = "Thanks for entering your profile. Ready to create your campaigns? "
          end
          redirect_to root_path
        else
          flash[:error] = "Please enter your profile information"
        end
    end
  end

  def upload_option
    @feeds = current_user.feeds
    if request.post?
      if params[:via].strip.downcase == "csv"
          redirect_to feeds_path
      elsif params[:via].strip.downcase == "xml"
          if params[:csv_file] and !params[:csv_file].downcase.strip.blank?
            if params[:csv_file].downcase == "update"
                @feeds.destroy_all
            end
          end
          url = params[:feed_url]
          if url.nil? or url.strip.blank?
            flash[:error] = "Please enter XML url"
            return
          end
          @xml_data = open(url).read
          @data = Hpricot::XML(@xml_data)
          (@data/:feed).each do |feed|
              @feed = Feed.new
              @feed.user = current_user
              @feed.card_type = (feed.at('card-type').innerHTML) if feed.at('card-type')
              @feed.last_four_account_number = (feed.at('last-four-account-number').innerHTML) if feed.at('last-four-account-number')
              @feed.ssn = (feed.at('ssn').innerHTML) if feed.at('ssn')
              @feed.balance = (feed.at('balance').innerHTML) if feed.at('balance')
              @feed.last_payment_date = (feed.at('last-payment-date').innerHTML).strip.to_date if feed.at('last-payment-date')
              @feed.credit_score = (feed.at('credit-score').innerHTML) if feed.at('credit-score')
              @feed.floor_limit = (feed.at('floor-limit').innerHTML) if feed.at('floor-limit')
              @feed.payment_term = (feed.at('payment-term').innerHTML) if feed.at('payment-term')
              @feed.expiry_date = (feed.at('expiry-date').innerHTML).strip.to_date if feed.at('expiry-date')
              @feed.user_dob = (feed.at('user-dob').innerHTML).strip.to_date if feed.at('user-dob')
              @feed.first_name = (feed.at('first-name').innerHTML) if feed.at('first-name')
              @feed.middle_name = (feed.at('middle-name').innerHTML) if feed.at('middle-name')
              @feed.last_name = (feed.at('last-name').innerHTML) if feed.at('last-name')
              @feed.address1 = (feed.at('address1').innerHTML) if feed.at('address1')
              @feed.address2 = (feed.at('address2').innerHTML) if feed.at('address2')
              @feed.city = (feed.at('city').innerHTML) if feed.at('city')
              @feed.state = (feed.at('state').innerHTML) if feed.at('state')
              @feed.zip = (feed.at('zip').innerHTML) if feed.at('zip')
              @feed.home_phone = (feed.at('home-phone').innerHTML) if feed.at('home-phone')
              @feed.mobile_phone = (feed.at('mobile-phone').innerHTML) if feed.at('mobile-phone')
              @feed.email = (feed.at('email').innerHTML) if feed.at('email')

              @feed.errors.add_to_base("Regular price must be atleast 1") if @feed.balance < 1
              if(@feed.valid? and @feed.errors.empty?)
                @feed.save
              end
          end
          flash[:notice]="Uploaded your file!"
          redirect_to root_path
      end
    end
  end

  def feeds
    @feeds = current_user.feeds
    if request.post?
      if !params[:uploaded_file].blank?
        file = params[:uploaded_file]
        FileUtils.mkdir_p "#{RAILS_ROOT}/public/uploads"

        file_path = "#{RAILS_ROOT}/public/uploads/#{Time.now.to_date}-#{file.original_filename}"
        if file_path.match(/(.*?)[.](.*?)/)
          mime_extension = File.mime_type?(file_path)
        else
          flash[:error]="Files in csv format please"
          return
        end

        if mime_extension.eql? "text/comma-separated-values" or mime_extension.eql? "text/csv"
            if params[:csv_file] and !params[:csv_file].downcase.strip.blank?
                if params[:csv_file].downcase == "update"
                    @feeds.destroy_all
                end
            end

            if !file.local_path.nil?
               FileUtils.copy_file(file.local_path,"#{file_path}")
            else
               File.open("#{file_path}", "wb") { |f| f.write(file.read) }
            end

            @file=File.open(file_path)
            n=0
            CSV::Reader.parse(File.open("#{file_path}", 'rb')) do |row|
                feed = Feed.new
                feed.user = current_user

                error = ""
                puts "========#{row.size}========================="
                if row.size == 22
                    feed.account_number = row[0]
                    feed.client_number = row[1]
                    feed.client_account_number = row[2]
                    feed.balance = row[3].delete("$,").to_f
                    feed.last_payment_date = row[4].strip
                    feed.last_pay_amount = row[5].delete("$,").to_f
                    feed.first_name = row[6]
                    feed.middle_name = row[7]
                    feed.last_name = row[8]
                    feed.address1 = row[9]
                    feed.address2 = row[10]
                    feed.city = row[11]
                    feed.state = row[12]
                    feed.zip = row[13]
                    feed.phone1 = row[14]
                    feed.phone2 = row[15]
                    feed.phone3 = row[16]
                    feed.phone4 = row[17]
                    feed.max_pct = row[18]
                    feed.payment_term = row[19]
                    feed.client_name1 = row[20]
                    feed.client_name2 = row[21]
                    feed.floor_limit = feed.balance - ((feed.balance * feed.max_pct) / 100)
                    #feed.floor_limit = (feed.balance * (100-feed.max_pct) / 100)

                    feed.errors.add_to_base("Regular price must be atleast 1") if feed.balance < 1
                    if(error.blank? and feed.errors.empty?)
                        feed.last_payment_date = row[4].strip.to_datetime
                        feed.save
                        n=n+1
                        GC.start if n%50==0
                    end
                end
            end
            if n==0
              flash[:notice] = "Uploaded file has the wrong columns. Plz. fix & re-upload"
            else
              flash[:notice]="Uploaded your file!"
              redirect_to root_path
            end
        else
            flash[:error]="Plz. upload a file with the correct format"
        end
      else
        flash[:error]="Please upload csv file" if params[:uploaded_file]
      end
    end
  end

  def manual_feed
    if request.post?
      @feed = Feed.new(params[:feed])
      @feed.user = current_user
      if @feed.save
        redirect_to root_path
      else
        flash[:error] = "Please enter valid information"
      end
    end
  end

  def verify_user
    @user = User.find_by_id(params[:id])
    if @user.nil?
      redirect_to root_path 
      return
    end
    if @user.is_verified == true
      flash[:notice] = "Account already Verified."
    else
      key = User.verify_user(@user.email)
      if params[:key] == key
        flash[:notice] = "Account Verified."
        @user.update_attribute(:is_verified, true)
        self.current_user = @user
      else
        flash[:notice] = "Account Not Verified."
      end
    end
    redirect_to root_path
  end

  def forgot
    flash[:error] = nil
    email = params[:email]
    if email and !email.strip.blank?
      @user = User.find_by_email(email)
      if @user.nil?
        flash[:error] = "No such ID, want to join?"
      else
        Notification.deliver_forgot_password(@user)
        flash[:notice] = "Yeah! Emailed you the password."
        redirect_to root_path
      end
    else
      flash[:error] = "Please enter valid information"
    end
  end

  def change_password
    if request.post?
        if params[:password].strip.blank?
          flash[:error] = "Please enter valid information"
        else
          if current_user.update_attribute("password", params[:password])
            flash[:notice] = "Password changed successfully"
            redirect_to root_path
          else
            flash[:error] = "Please enter valid information"
          end
        end
    end
  end

	def destroy_feed
    if request.xhr?
      id = params[:id]
      Feed.destroy(id)
      render :update do |page|
          page.visual_effect :squish, "feed_#{id}", :duration => 0.5
      end
    end
	end

  def destroy
    logout_killing_session!
    session[:user_id] = nil
    flash[:notice] = "You have ended your session."
    redirect_back_or_default('/')
  end

  def profile_logo
    #user= User.find(params[:id])
    profile = Profile.find(params[:id])
    style = params[:style] ? params[:style] : 'original'
    send_file profile.logo.path(style),
              :type => profile.logo_content_type
  end
  
end
