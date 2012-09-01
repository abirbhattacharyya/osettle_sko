class Feed < ActiveRecord::Base
  belongs_to :user
  has_many :offers, :dependent => :destroy

  validates_presence_of :first_name, :message => "^Hey, First name can't be blank"
  validates_presence_of :middle_name, :message => "^Hey, Middle name can't be blank"
  validates_presence_of :last_name, :message => "^Hey, Last name can't be blank"
  validates_presence_of :city, :message => "^Hey, city can't be blank"
  validates_presence_of :state, :message => "^Hey, state can't be blank"
  validates_presence_of :zip, :message => "^Hey, zip can't be blank"
  validates_presence_of :phone1, :message => "^Hey, home phone can't be blank"
  validates_presence_of :email, :message => "^Hey, email can't be blank",:on => :update

  validates_uniqueness_of :account_number
  
  validate :valid_address

  ADDRESS = [
["10004","New York","NY"],
["94027","Atherton","CA"],
["90067","Los Angeles","CA"],
["89451","Incline Village Crystal Bay","NV"],
["98039","Medina","WA"],
["06831","Greenwich","CT"],
["33480","Palm Beach","FL"],
["07620","Alpine","NJ"],
["11568","Old Westbury","NY"],
["33921","Boca Grande","FL"],
["92067","Rancho Santa Fe","CA"],
["07931","Far Hills","NJ"],
["60043","Kenilworth","IL"],
["06830","Greenwich","CT"],
["94028","Portola Valley","CA"],
["90210","Beverly Hills","CA"],
["92657","Newport Coast","CA"],
["74103","Tulsa","OK"],
["06840","New Canaan","CT"],
["02493","Weston","MA"],
["94111","San Francisco","CA"],
["60606","Chicago","IL"],
["60093","Winnetka","IL"],
["10580","Rye","NY"],
["10018","New York","NY"],
["76102","Fort Worth","TX"],
["02108","Boston","MA"],
["06820","Darien","CT"],
["02110","Boston","MA"],
["60022","Glencoe","IL"],
["90077","Los Angeles","CA"],
["85253","Paradise Valley","AZ"],
["23219","Richmond","VA"],
["60045","Lake Forest","IL"],
["34102","Naples","FL"],
["10514","Chappaqua","NY"],
["10506","Bedford","NY"],
["63124","Ladue","MO"],
["07021","Essex Fells","NJ"],
["34228","Longboat Key","FL"],
["19807","Wilmington","DE"],
["94022","Los Altos","CA"],
["10504","Armonk","NY"],
["02030","Dover","MA"],
["78257","San Antonio","TX"],
["06883","Weston","CT"],
["10022","New York","NY"],
["94304","Palo Alto","CA"],
["10021","New York","NY"],
["83014","Wilson","WY"],
["94920","Belvedere","CA"],
["02199","Boston","MA"],
["32963","South Beach","FL"],
["75205","Dallas","TX"],
["94301","Palo Alto","CA"],
["10069","New York","NY"],
["11024","Kings Point","NY"],
["90402","Santa Monica","CA"],
["07760","Rumson","NJ"],
["07458","Saddle River","NJ"],
["10576","Scotts Corners","NY"],
["06880","Westport","CT"],
["06853","Norwalk","CT"],
["77002","Houston","TX"],
["22066","Great Falls","VA"],
["07046","Mountain Lakes","NJ"],
["75225","Dallas","TX"],
["30326","Atlanta","GA"],
["92091","Rancho Santa Fe","CA"],
["11724","Cold Spring Harbor","NY"],
["93108","Santa Barbara","CA"],
["10583","Scarsdale","NY"],
["60521","Hinsdale","IL"],
["07417","Franklin Lakes","NJ"],
["77024","Hunters Creek Village","TX"],
["90212","Beverly Hills","CA"],
["28207","Charlotte","NC"],
["11030","Manhasset","NY"],
["02109","Boston","MA"],
["34108","Naples Park","FL"],
["10538","Larchmont","NY"],
["20854","Potomac","MD"],
["07924","Bernardsville","NJ"],
["07945","Mendham","NJ"],
["10028","New York","NY"],
["60611","Chicago","IL"],
["01770","Sherborn","MA"],
["10017","New York","NY"],
["33786","Belleair Beach","FL"],
["20198","The Plains","VA"],
["94062","Redwood City","CA"]
  ]

  private

  def valid_address
    if(self.address1 and self.address2)
        self.errors.add(:address1, "^Hey, please enter address line1 or line2") if(self.address1.strip.blank? and self.address2.strip.blank?)
    end
  end
end
