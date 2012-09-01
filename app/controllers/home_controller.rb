require 'fileutils'
require 'csv'
require 'gattica'
class HomeController < ApplicationController
  before_filter :check_login, :except => [:index, :privacy, :change_feeds, :feeds_appened, :daily_report, :daily_payment_report,:generate_report_data]

  def index
    if logged_in?
        if current_user.biz?
          if current_user.is_verified == true
            if current_user.profile.nil?
              render :template => "/users/profile"
            elsif current_user.feeds.size <= 0
              @feeds = current_user.feeds
              render :template => "/users/upload_option"
            else
              @notifications = [["profile", current_user.profile.created_at],["feeds", current_user.feeds.last.created_at]]
              @notifications.sort!{|n1, n2| n2[1] <=> n1[1]}
              render :template => "/home/notifications"
            end
          end
        elsif current_user.is_verified == false
          render :template => "/users/agree"
        else
          @feed = current_user.feed_info
          if !@feed.phone1.blank? and !@feed.email.blank?#session[:skip_verify]
            @offer = @feed.offers.last(:conditions => ["response IS NULL"])
            @counter_offer = @feed.offers.last(:conditions => ["response like(?) or response like (?)", "counter", "last"])
            @accepted_offer = @feed.offers.last(:conditions => ["response like(?)", "accepted"])
            @rejected_offer = @feed.offers.last(:conditions => ["response like(?)", "rejected"])
            if @accepted_offer
              if @accepted_offer.payment.nil?
                render :template => "/users/settlement"
              else
                render :template => "/home/complete_payment"
              end
            elsif  @rejected_offer           
                @offer = @rejected_offer
                @counter_offer  = @rejected_offer
                @counter_offer.response = "last"
                @counter_offer.save
               render :template => "/users/negotiate"
            else
              if @offer
                render :template => "/users/negotiate"
              else
                render :template => "/home/capsule"
              end
            end
          else
            @feed.phone1 = nil
            render :template => "/users/verify"
          end
        end
    else
        render :template => "/users/login"
    end
  end

  def complete_payment
    @feed = current_user.feed_info
    @accepted_offer = @feed.offers.last(:conditions => ["response like(?)", "accepted"])
    if request.post?
      if @feed.update_attributes(params[:feed])
        flash[:notice] = "An agent will call you shortly. Thank You."
        redirect_to root_path
      else
        flash[:notice] = "Enter valid information"
      end
    end
  end
  
  def notifications
    @notifications = [["profile", current_user.profile.created_at],["feeds", current_user.feeds.last.created_at]]
    @notifications.sort!{|n1, n2| n2[1] <=> n1[1]}
  end	  

  def analytics
    if request.post?
      @page = params[:page].to_i
    else
      @page = 1
    end
    @size = 6
    @per_page = 1
    @post_pages = (@size.to_f/@per_page).ceil;
    @page =1 if @page.to_i<=0 or @page.to_i > @post_pages
    @titleX = "Stages"
    @titleY = "#"
    @colors = []

    case @page
      when 1
        @title = "# By Stages"
        @chart_data1 = [["# Logged in week1", 48000], ["# Logged in week2", 32000], ["# offers made week1", 45000], ["# offers made week2", 25000], ["# agreement reached week1", 35000], ["# agreement reached week2", 15000]]
      when 2
        @title = "% By Stages"
        @chart_data1 = [["% Logged in week1", 60], ["% Logged in week2", 40], ["% offers made week1", 64.28], ["% offers made week2", (100-64.28)], ["% agreement reached week1", 70], ["% agreement reached week2", 30]]
      when 3
        @title = "# of payments made"
        @chart_data1 = [["# payment made week1", 20000], ["# payment made week2", 10000]]
      when 4
        @title = "% payments made"
        @chart_data1 = [["% payment made week1", 66.67], ["% payment made week2", (100-66.67)]]
      when 5
        @title = "Stages with $ balances"
        logged_in_week1 = Feed.first(:select => "SUM(balance) as total", :conditions => ["id <= ?", 48000])
        logged_in_week2 = Feed.first(:select => "SUM(balance) as total", :conditions => ["id > ? and id <= ?", 50000, 82000])
        offers_in_week1 = Offer.first(:select => "SUM(amount) as total", :conditions => ["response like (?) and (Date(created_at) >= ? and Date(created_at) <= ?)", "counter", '2010-11-01', '2010-11-07'])
        offers_in_week2 = Offer.first(:select => "SUM(amount) as total", :conditions => ["response like (?) and (Date(created_at) >= ? and Date(created_at) <= ?)", "counter", '2010-11-08', '2010-11-14'])
        agreement_in_week1 = Offer.first(:select => "SUM(amount) as total", :conditions => ["response like (?) and (Date(created_at) >= ? and Date(created_at) <= ?)", "accepted", '2010-11-01', '2010-11-07'])
        agreement_in_week2 = Offer.first(:select => "SUM(amount) as total", :conditions => ["response like (?) and (Date(created_at) >= ? and Date(created_at) <= ?)", "accepted", '2010-11-08', '2010-11-14'])

        logged_all = (logged_in_week1.total.to_i + logged_in_week2.total.to_i)
        logged_week1 = 0; logged_week2 = 0;
        offers_all = (offers_in_week1.total.to_i + offers_in_week2.total.to_i)
        offer_week1 = 0; offer_week2 = 0
        agreements_all = (agreement_in_week1.total.to_i + agreement_in_week2.total.to_i)
        agreement_week1 = 0; agreement_week2 = 0
        if(logged_all > 0)
          logged_week1 = (logged_in_week1.total.to_f*100/logged_all)
          logged_week2 = (logged_in_week2.total.to_f*100/logged_all)
        end
        if(offers_all > 0)
          offer_week1 = (offers_in_week1.total.to_f*100/offers_all)
          offer_week2 = (offers_in_week2.total.to_f*100/offers_all)
        end
        if(agreements_all > 0)
          agreement_week1 = (agreement_in_week1.total.to_f*100/agreements_all)
          agreement_week2 = (agreement_in_week2.total.to_f*100/agreements_all)
        end
        @chart_data1 = [
            ["% Logged in week1", logged_week1], ["% Logged in week2", logged_week2],
            ["% offers made week1", offer_week1], ["% offers made week2", offer_week2],
            ["% agreement reached week1", agreement_week1], ["% agreement reached week2", agreement_week2]
        ]
    when 6
        @title = "Site Activity Summary"
        feeds = Feed.first(:select => "COUNT(*) as size")
        users = User.first(:select => "COUNT(*) as size", :conditions => ["email IS NULL"])
        made_offers = Offer.first(:select => "COUNT(*) as size", :conditions => ["response like (?) or response like (?)", "accepted", "counter"])
        accepted_offers = Offer.first(:select => "COUNT(*) as size", :conditions => ["response like (?)", "accepted"])
        payments = Payment.first(:select => "COUNT(*) as size")
        @chart_data1 = [
            ["Mailed Invitations", feeds.size.to_i],
            ["Logins Completed", users.size.to_i],
            ["Offers Made", made_offers.size.to_i],
            ["Offers Accepted", accepted_offers.size.to_i],
            ["Payments Made", payments.size.to_i]
        ]
      else
        @title = "# by Stages"
        @chart_data1 = [["# Logged in week1", 48000], ["# Logged in week2", 32000]]
    end
  end

  def view_data
    if request.post?
      @page = params[:page].to_i
      @sort = params[:sort].to_i
      @sort_type = params[:sort_type].to_i
    else
      @page = 1
      @sort = 0
      @sort_type = 1
    end
    feeds = Feed.first(:select => "count(id) as size", :conditions => ["user_id=?", current_user.id])
    @size = feeds.size.to_i
    @per_page = 25
    @post_pages = (@size.to_f/@per_page).ceil;
    @page =1 if @page.to_i<=0 or @page.to_i > @post_pages
    @feeds = current_user.feeds.all(:limit => "#{@per_page*(@page - 1)}, #{@per_page}")
    case @sort
      when -1
        @feeds.sort!{|feed1,feed2| feed2.client_number <=> feed1.client_number}
      when 1
        if @sort_type==1
          flash[:notice] = "Sorted by Client number in Descending Order"
          @feeds.sort!{|feed2,feed1| feed1.client_number <=> feed2.client_number}
        else
          flash[:notice] = "Sorted by Client number in Ascending Order"
          @feeds.sort!{|feed1,feed2| feed1.client_number <=> feed2.client_number}
        end
      when 2
        if @sort_type==1
          flash[:notice] = "Sorted by Balance in Descending Order"
          @feeds.sort!{|feed2,feed1| feed1.balance <=> feed2.balance}
        else
          flash[:notice] = "Sorted by Balance in Ascending Order"
          @feeds.sort!{|feed1,feed2| feed1.balance <=> feed2.balance}
        end
      when 3
        if @sort_type==1
          flash[:notice] = "Sorted by Floor Limit in Descending Order"
          @feeds.sort!{|feed2,feed1| feed1.floor_limit <=> feed2.floor_limit}
        else
          flash[:notice] = "Sorted by Floor Limit in Ascending Order"
          @feeds.sort!{|feed1,feed2| feed1.floor_limit <=> feed2.floor_limit}
        end

      when 4
        if @sort_type==1
          flash[:notice] = "Sorted by Payment Term in Descending Order"
          @feeds.sort!{|feed2,feed1| feed1.payment_term <=> feed2.payment_term}
        else
          flash[:notice] = "Sorted by Payment Term in Ascending Order"
          @feeds.sort!{|feed1,feed2| feed1.payment_term <=> feed2.payment_term}
        end
      when 5
        if @sort_type==1
          flash[:notice] = "Sorted by last payment date in Descending Order"
          @feeds.sort!{|feed2,feed1| feed1.last_payment_date <=> feed2.last_payment_date}
        else
          flash[:notice] = "Sorted by last payment date in Ascending Order"
          @feeds.sort!{|feed1,feed2| feed1.last_payment_date <=> feed2.last_payment_date}
        end    
    end
  end
	
	def observe_consumers_data
		@page = 1
		@sort = 0
		@sort_type = 1
		feeds = Feed.first(:select => "count(id) as size", :conditions => ["user_id=? and (client_number like ?  OR first_name LIKE (?) or last_name LIKE (?) or  balance = (?))", current_user.id, "%"+params[:details].to_s+"%","%"+params[:details].to_s+"%", "%"+params[:details].to_s+"%","%"+params[:details].to_s+"%"])
		@size = feeds.size.to_i
		@per_page = 25
		@post_pages = (@size.to_f/@per_page).ceil;
		@page =1 if @page.to_i<=0 or @page.to_i > @post_pages
		@feeds = current_user.feeds.all(:conditions=>["client_number like ?  OR first_name LIKE (?) or last_name LIKE (?) or balance = (?)", "%"+params[:details].to_s+"%","%"+params[:details].to_s+"%","%"+params[:details].to_s+"%",params[:details]], :limit => "#{@per_page*(@page - 1)}, #{@per_page}")
		render :layout =>false
	end
  
	def faq
		
	end 	
	
	def privacy
		
	end

  def reports
      query = ""
      @from = ""
      @to = ""
      if request.post?
        @from = params[:from]
        @to = params[:to]
        if @from and @to
          query = "(Date(created_at) between '#{@from.to_date}' and '#{@to.to_date}')"
        else
          flash[:error] = "From Date and To Date cannot be blank"
        end
      end
      feeds = Feed.first(:select => "COUNT(*) as size", :conditions => ["#{query}"])
      users = User.first(:select => "COUNT(*) as size", :conditions => ["#{query.blank? ? query : "#{query} and "} email IS NULL"])
      made_offers = Offer.first(:select => "COUNT(*) as size, SUM(amount) as total_amount", :conditions => ["#{query.blank? ? query : "#{query} and "} response like (?) or response like (?)", "accepted", "counter"])
      accepted_offers = Offer.first(:select => "COUNT(*) as size, SUM(amount) as total_amount", :conditions => ["#{query.blank? ? query : "#{query} and "} response like (?)", "accepted"])
      payments = Payment.first(:select => "COUNT(*) as size, SUM(amount) as total_amount", :conditions => [request.post? ? "(Date(payment_date) between '#{@from.to_date}' and '#{@to.to_date}')" : ""])
      @report = [["Mailed Invitations", feeds.size.to_i],
          ["Logins Completed", users.size.to_i],
          ["Offers Made", made_offers.size.to_i],
          ["Offers Accepted", accepted_offers.size.to_i],
          ["Payments Made", payments.size.to_i],
          ["$ Offers Made", made_offers.total_amount.to_i],
          ["$ Offers Accepted", accepted_offers.total_amount.to_i],
          ["$ Payments Made", payments.total_amount.to_i]]
    
  end

  def daily_report
    #reports

    #@today = DateTime.now.in_time_zone("Pacific Time (US & Canada)")
    user_count,page_views,avg_time_on_site,started_negotiate,dollar_started_negotiate,avg_round,reach_settlement,avg_settlement,made_payment,avg_payment_amount = generate_report_data(false)
    user_count_all,page_views_all,avg_time_on_site_all,started_negotiate_all,dollar_started_negotiate_all,avg_round_all,reach_settlement_all,avg_settlement_all,made_payment_all,avg_payment_amount_all = generate_report_data(true)

    @report = [
          ["Logins Completed",user_count,user_count_all],
          ["Page Views",page_views,page_views_all],
          ["Average Time On Site",avg_time_on_site,avg_time_on_site_all],
          ["Started Negotiating",started_negotiate,started_negotiate_all],
          ["Total $ Of Accounts That Started Negotiating",dollar_started_negotiate,dollar_started_negotiate_all],
          ["Average # Of Rounds",avg_round,avg_round_all],
          ["Reached Settlement", reach_settlement,reach_settlement_all],
          ["$ Average Settlement",avg_settlement,avg_settlement_all],
          ["Made Payments",made_payment,made_payment_all],
          ["$ Average Payment",avg_payment_amount,avg_payment_amount_all]
          ]
    
    Notification.deliver_daily_report(@report)
    flash[:notice] ="Daily Report is sent"
    redirect_to root_path
  end

  def daily_payment_report
    from = DateTime.now.in_time_zone("Pacific Time (US & Canada)") - 1.day
    from = from.beginning_of_day
    to  = from.end_of_day
    payments = Payment.find(:all,:conditions => ["CONVERT_TZ(created_at,'+0:00','-7:00') between ? AND ? and payment_type  != 'decline'",from ,to])
    FileUtils.mkdir_p(REPORT_FILE_PATH)
    file_name = "#{Time.now.strftime('%Y_%m_%d')}.csv"
    report = File.open("#{REPORT_FILE_PATH}/#{file_name}","wb")
    CSV::Writer.generate(report) { |csv|  
      csv << ["First Name","Last Name","Address 1", "Address 2", "City", "State", "Zip","Credit Card Number","Credit Card Type","Expiration Date","Bank Account Number","Route Number","Bank Name","Date Of Payment", "Settlement Amount ($)","Number Of Payments"]
     payments.each do |payment|
     #for payment in payments
        feed = payment.offer.feed
        first_name = feed.first_name
        last_name = feed.last_name
        address1 = feed.address1
        address2 = feed.address2
        city = feed.city
        state = feed.state
        zip = feed.zip
        cc_no = payment.cc_no.to_i + 8837 if !payment.cc_no.blank?
        cc_type = payment.cc_type
        expiry_date = "#{payment.cc_expiry_m}/#{payment.cc_expiry_y}" if !payment.cc_expiry_m.blank? and !payment.cc_expiry_y.blank?
        bank_ac_no = payment.bank_ac_no.to_i + 8837 if !payment.bank_ac_no.blank?
        route_number = payment.routing_no if !payment.routing_no.blank?
        bank_name = payment.bank_name if !payment.bank_name.blank?
        date_payment = payment.created_at.to_date
        settle_amt = payment.amount
        number_of_payments = (payment.payment_type == "full") ? 1 : feed.payment_term
        csv << [first_name,last_name,address1,address2,city,state,zip,cc_no,cc_type,expiry_date,bank_ac_no,route_number,bank_name,date_payment,settle_amt,number_of_payments]
      end
    }
    report.close
    #render :template => "notification/daily_payment_report"
    Notification.deliver_daily_payment_report(file_name)
    flash[:notice] ="Daily Payment Report is sent"
    redirect_to root_path
  end

	def feeds_appened

    (0...1000).each do

      @feeds = Feed.new
      
      @ac_no = Array.new
      @cl_no = Array.new
      @cl_ac_no = Array.new
      @p_no1 = Array.new
      @p_no2 = Array.new
      @p_no3 = Array.new
      @p_no4 = Array.new
      @add_no = Array.new
      
      (0...11).each do
        @ac_no << rand(9)+1
      end

      (0...4).each do
        @cl_no << rand(9)+1
      end

      (0...6).each do
        @cl_ac_no << rand(9)+1
      end

      (0...7).each do
        @p_no1 << rand(9)+1
      end

      (0...7).each do
        @p_no2 << rand(9)+1
      end

      (0...7).each do
        @p_no3 << rand(9)+1
      end

      (0...7).each do
        @p_no4 << rand(9)+1
      end

      (0...3).each do
        @add_no << rand(9)+1
      end

      @fir_nam = (File.open("#{RAILS_ROOT}/public/uploads/firstName.csv")).to_a
      @las_nam = (File.open("#{RAILS_ROOT}/public/uploads/lastName.csv")).to_a

      @fir_na_no = rand(@fir_nam.length)+0
      @las_na_no = rand(@las_nam.length)+0

#      render :text=>@fir_nam[@fir_na_no].strip.inspect and return false

			date1 = Time.local(2010,1,1)
      date2 = Time.now
      
      @rand_date = Time.at((date2.to_f - date1.to_f)*rand + date1.to_f)

#      render :text=>@f1 and return false
#      render :text=>(rand(25)+65).chr and return false

      @feeds.user_id = 1
      @feeds.account_number = @ac_no.to_s.to_i
      @feeds.client_number = "PRD" + @cl_no.to_s
      @feeds.client_account_number = @cl_ac_no.to_s
      @feeds.balance = rand(1250) + 250
      @feeds.last_payment_date = @rand_date
      @feeds.last_pay_amount = rand(1250) + 250
      @feeds.max_pct = rand(25) + 25
      @feeds.floor_limit = ((@feeds.balance * (100-@feeds.max_pct)) / 100).ceil
      @feeds.payment_term = rand(12) + 1

      @feeds.first_name = @fir_nam[@fir_na_no].strip
      @feeds.middle_name = (rand(25)+65).chr.to_s
      @feeds.last_name = @las_nam[@las_na_no].strip

      address_id = (rand(999)%Feed::ADDRESS.size).to_i
#      feed.update_attributes(:address1 => "#{@add_no.to_s.to_i} Main Street", :address2 => "#{@add_no.to_s.to_i} Main Street", :city => Feed::ADDRESS[address_id][1], :state => Feed::ADDRESS[address_id][2], :zip => Feed::ADDRESS[address_id][0])

      @feeds.address1 = "#{@add_no.to_s.to_i} Main Street"
      @feeds.address2 = "#{@add_no.to_s.to_i} Main Street"
      @feeds.city = Feed::ADDRESS[address_id][1]
      @feeds.state = Feed::ADDRESS[address_id][2]
      @feeds.zip = Feed::ADDRESS[address_id][0]
      @feeds.phone1 = ("405" + @p_no1.to_s).to_i
      @feeds.phone2 = ("405" + @p_no2.to_s).to_i
      @feeds.phone3 = ("405" + @p_no3.to_s).to_i
      @feeds.phone4 = ("405" + @p_no4.to_s).to_i

      @feeds.client_name1 = @fir_nam[@fir_na_no].strip
      @feeds.client_name2 = @fir_nam[@fir_na_no].strip

#      render :text=>@feeds.inspect and return false
      @feeds.save

    end
    render :text=>"All done" and return false
  end



  def change_days
    current_time = Time.now.in_time_zone("Pacific Time (US & Canada)")
    @month = params[:month].to_i

    @day_range = Array.new
    if current_time.month == @month

      @day_range = day_options
      @day = current_time.day
      @year = current_time.year
    else


      next_month = current_time + 30.days
      from_day = next_month.beginning_of_month.day
      end_day = next_month.day
      from_day.upto(end_day) do|day|
        @day_range.push(day)
      end
      @year = next_month.year
    end

    render :layout => false
  end

  private

  def generate_report_data(all = true)
    @today = DateTime.now.in_time_zone("Pacific Time (US & Canada)")
    query = "1 "
    join_query = "1 "
    if all == false
      to =  (@today - 1.day).end_of_day
      query += "AND CONVERT_TZ(created_at,'+0:00','-7:00') <= '#{to}'"
      join_query += "AND CONVERT_TZ(offers.created_at,'+0:00','-7:00') <= '#{to}'"
    else
      to = @today
    end
    users = User.first(:select => "COUNT(*) as size", :conditions => ["email IS NULL AND #{query}"])
    accepted_offers = Offer.first(:select => "COUNT(*) as size, SUM(amount) as total_amount", :conditions => ["response like (?) AND #{query}", "accepted"])
    payments = Payment.first(:select => "COUNT(*) as size, SUM(amount) as total_amount",:conditions =>["#{query}"])

    start_negotiate = Offer.find(:all,:select =>["DISTINCT (feed_id)"],:conditions =>["#{query}"])

    started_negotiate_in_dollar = Offer.find(:all,:select => ["feeds.balance"],:joins => ["LEFT JOIN feeds ON offers.feed_id = feeds.id"],:conditions =>["#{join_query}"],:group => "offers.feed_id")
    negotiate_amount =started_negotiate_in_dollar.map{|m| m.balance.to_i}.sum

    avg_rounds_recs = Offer.find(:all,:select =>["feed_id, count(*) as cnt"],:conditions =>["#{query}"],:group => "feed_id")

    avg_rounds = avg_rounds_recs.size >0 ? avg_rounds_recs.map{|m| m.cnt.to_i}.sum / avg_rounds_recs.size : 0

    avg_accepted_offers = Offer.first(:select => "COUNT(*) as size, AVG(amount) as total_amount", :conditions => ["response like (?) AND #{query}", "accepted"])
    avg_payments = Payment.first(:select => "COUNT(*) as size, AVG(amount) as total_amount",:conditions =>["#{query}"])

    
    analytics_overall = analytics_details('2011-05-29', to.to_date)
    avg_time = (analytics_overall["timeOnSite"].to_f/(analytics_overall["visits"].to_f > 0 ? analytics_overall["visits"].to_f : 1)).ceil
    hour,min,sec = convert_seconds_to_time(avg_time)
    return users.size.to_i,analytics_overall["pageviews"],"#{hour}:#{min}:#{sec}",start_negotiate.size.to_i,negotiate_amount.to_i,avg_rounds.to_i,accepted_offers.size.to_i,avg_accepted_offers.total_amount.to_i,payments.size.to_i,avg_payments.total_amount.to_i

  end

end
