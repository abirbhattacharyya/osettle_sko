class Payment < ActiveRecord::Base
  belongs_to :offer

#  validates_presence_of :name, :message => "^Hey, name can't be blank"
#  validates_presence_of :cc_no, :message => "^Hey, credit card# can't be blank"
#  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "^Hey, please enter valid email", :if => :email

  attr_accessor :cc_expiry_m1, :cc_expiry_m2, :acc_type, :account_holders_name

  validate :check_acount


  CARD_TYPE = [["Visa", "visa"], ["MasterCard", "master"]]
  

  private




  def check_acount
    if self.acc_type
      if self.acc_type.strip.downcase == "bank"
        self.errors.add(:account_holders_name, "^Hey, account holders name can't be blank") if self.account_holders_name.nil? or self.account_holders_name.strip.blank?
        self.errors.add(:bank_ac_no, "^Hey, bank acount # can't be blank") if self.bank_ac_no.nil? or self.bank_ac_no.strip.blank?
        self.errors.add(:routing_no, "^Hey, routing # can't be blank") if self.routing_no.nil? or self.routing_no.strip.blank?
        self.errors.add(:bank_name, "^Hey, bank name can't be blank") if self.bank_name.nil? or self.bank_name.strip.blank?

        self.name = nil
        self.email = nil
        self.cc_no = nil
        self.cc_type = nil
        self.cc_expiry_m = nil
        self.cc_expiry_y = nil
        self.security_code = nil
        self.billing_address = nil
        self.city = nil
        self.state = nil
        self.zip = nil
      else
        self.errors.add(:name, "^Hey, name can't be blank") if self.name.nil? or self.name.strip.blank?
        self.errors.add(:email, "^Hey, email can't be blank") if self.email.nil? or self.email.strip.blank?
        self.errors.add(:cc_no, "^Hey, credit card # can't be blank") if self.cc_no.nil? or self.cc_no.strip.blank?
        self.errors.add(:cc_type, "^Hey, credit card type can't be blank") if self.cc_type.nil? or self.cc_type.strip.blank?
        self.errors.add(:security_code, "^Hey, security code can't be blank") if self.security_code.to_i <= 0
        self.errors.add(:billing_address, "^Hey, billing address can't be blank") if self.billing_address.nil? or self.billing_address.strip.blank?
        self.errors.add(:city, "^Hey, city can't be blank") if self.city.nil? or self.city.strip.blank?
        self.errors.add(:state, "^Hey, state can't be blank") if self.state.nil? or self.state.strip.blank?
        self.errors.add(:zip, "^Hey, zip can't be blank") if self.zip.to_i <= 0

        if self.cc_expiry_y == Date.today.year
          self.cc_expiry_m = self.cc_expiry_m1
        else
          self.cc_expiry_m = self.cc_expiry_m2
        end
        
        self.account_holders_name = nil
        self.bank_ac_no = nil
        self.routing_no = nil
        self.bank_name = nil
      end
    end
  end
end
