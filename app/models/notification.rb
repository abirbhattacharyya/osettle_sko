class Notification < ActionMailer::Base
  default_url_options[:host] = "osettle.com"

  def signup_notification(user,sent_on = Time.now)
    subject    'Thanks for joining us'
    recipients user.email
    from       sender_email
    body       :user => user

    content_type 'text/html'
  end

  def forgot_password(user,sent_on = Time.now)
    subject    'Your forgotten password for Osettle'
    recipients user.email
    from       sender_email
    body       :user => user

    content_type 'text/html'
  end

  def agreed_deal_biz(payment,email,name,sent_on = Time.now)
    subject 'Successful Settlement'
    recipients "\"#{name}\" <#{email}>"
    from       "\"SettleDirect Control Panel\" <dealkat@dealkat.com>"
    body       :payment => payment

    content_type 'text/html'
  end
  
  def agreed_deal_customer(payment,sent_on = Time.now)
    subject 'Confirmation of your Settlement'
    recipients "\"#{payment.name}\" <#{payment.email}>"
    from       "\"Acme SettleDirect Administrator\" <dealkat@dealkat.com>"
    body       :payment => payment

    content_type 'text/html'
  end

  def daily_report(report)
    subject    'Sko Site Activity Daily Report'
    bcc         BCC_EMAILS
   # bcc         'brijeshshah86@gmail.com,dhaval.parikh33@gmail.com'
    from       sender_email
    body       :report => report

    content_type 'text/html'
  end

  def daily_payment_report(file)
    subject    'Sko Daily Payment Report'
     bcc         BCC_EMAILS
   #bcc         'brijeshshah86@gmail.com,dhaval.parikh33@gmail.com'
    from       sender_email
    body       "Daily Payment Report"
    attachment :body => File.read("#{REPORT_FILE_PATH}/#{file}"),:content_type => "text/csv",:filename => "payment_report_#{file}"
    
  end

  def decline_email(id)
    feed = Feed.find(id)
     subject    'Please finish renegotiating your debt'
     bcc         feed.email
   #bcc         'brijeshshah86@gmail.com,dhaval.parikh33@gmail.com'
    from       sender_email
    body       :feed => feed
  end

  protected

  def sender_email
      "\"Osettle\" <osettle@osettle.com>"
  end
end
