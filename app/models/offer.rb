class Offer < ActiveRecord::Base
  belongs_to :feed
  has_one :payment, :dependent => :destroy

  validates_presence_of :amount, :message => "^Hey, offer can't be blank"

  PAYMENT_TYPE = ["full", "monthly"]
  
  def change_amount(new_amount)
    update_attribute(:amount, new_amount)
  end

  def expire
    update_attribute(:response, "expired")
  end

  def accept
    update_attribute(:response, "accepted")
  end

  def reject
    update_attribute(:response, "rejected")
  end

  def last?
    (response == "last")
  end
end
