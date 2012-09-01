# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include GoogleVisualization
  
  #$PROFILE_NAME = Profile.first.name

  def generate_number(lim)
    array = [rand(999)%8 + 1]
    array = array.concat((2..lim).map{ rand(999)%10 })
    return array * ""
  end

  def option_tags_days(month)
      option_tag = ""
      1.upto(month.to_i) do |i|
          option_tag += "<option value=#{i}>#{i}</option>"
      end
      option_tag
  end

  def option_tags_months
      option_tag = ""
      1.upto(12) do |i|
          option_tag += "<option value=#{i}>#{i}</option>"
      end
      option_tag
  end
  
  def analytics_details(from, to)
    gs = Gattica.new({:email => 'dealkat@gmail.com', :password => "princessthecat", :profile_id => 46544806})
    results = gs.get({:start_date => from.to_s, :end_date => to.to_s,
                :dimensions => ['medium', 'source'], :metrics => ['pageviews', 'visits', 'timeOnSite'], :sort => '-pageviews'})
    @xml_data = results.to_xml
    @data = Hpricot::XML(@xml_data)
    analytics = {}
    (@data/'dxp:aggregates').each do |aggregate|
      (aggregate/'dxp:metric').each do |metric|
          analytics["pageviews"] = metric[:value] if metric[:name] == "ga:pageviews"
          analytics["visits"] = metric[:value] if metric[:name] == "ga:visits"
          analytics["timeOnSite"] = metric[:value] if metric[:name] == "ga:timeOnSite"
      end
    end
    return analytics
  end

  def convert_seconds_to_time(seconds)
    h,   ss = seconds.divmod(3600)
    min, s  = ss.divmod(60)
    return h, min, s
  end



  def get_current_time

    time = Time.now.in_time_zone("Pacific Time (US & Canada)")

    return time


  end


  def month_options

    from = get_current_time.to_date
    to  = from + 30.days
    months = Array.new
    months.push(from.month)
    months.push(to.month)

    return months.uniq
  end

  def day_options

    from = get_current_time.day
    to  = get_current_time.end_of_month.day
    days = Array.new
    from.upto(to) do |i|
    days.push(i)
    end

    return days
  end

  def year_options
    from  = get_current_time
    to  = from + 30.days
    year = Array.new
    year.push(from.year)
    year.push(to.year)

    return year.uniq
  end



end
