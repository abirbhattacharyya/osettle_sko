class User < ActiveRecord::Base
  has_one :profile, :dependent => :destroy
  has_many :feeds, :dependent => :destroy

  validates_format_of       :password, :with=> /(?!^[0-9]*$)(?!^[a-zA-Z]*$)^([a-zA-Z0-9]{8,40})$/, :message => "^Hey, Password should contain At least 8 characters and at least 1 number", :if => :password_required?
  validates_format_of       :email, :if => :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  validates_uniqueness_of   :email, :case_sensitive => false, :if => :email, :message => "^Hey, incorrect email/password combination."

  MONTH_NAMES = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

  def self.authenticate(email, password)
    return nil if email.blank? || password.blank?
    u = find :first, :conditions => ['email = ? and password=?', email, password] # need to get the salt
    return u
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

	def self.verify_user(email, dt="dealkat")
		Digest::SHA256.hexdigest("#{email}#{dt}")
	end

  def biz?
    email and password
  end

  def feed_info
    Feed.first(:conditions => ["account_number = ?", self.account_number])
  end

  protected

  def password_required?
      !(password.nil?)
  end

  def password_blank?
      (password.nil?)
  end
end
