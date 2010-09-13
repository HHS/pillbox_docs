class Patient < ActiveRecord::Base
  has_many :ailments, :order=>'name'
  belongs_to :user
  after_create :ensure_ailments
  
  def ensure_ailments
    if ailments.empty?
      what_ails_ya = TREATMENTS.keys[rand(TREATMENTS.size)]
      self.ailments.create :name=> what_ails_ya, :pill=>Pill.find_by_name(TREATMENTS[what_ails_ya])
    end
  end
  
  TREATMENTS = {
  "hiv"=>  "acetaminophen",
  "cancer"=>  "acetaminophen",
  "trauma"=>  "acetaminophen",
  "schitzophrenia"=>  "acetaminophen",
  "sneezing"=>  "acetaminophen",
  "coughing"=>  "acetaminophen",
  "anxiety"=>  "acetaminophen"

#  "headache"=>  "acetaminophen",
#  "fever"=>     "aspirin",
#  "bacterial infection"=>"erythromycin",
#  "viral infection"=>"tamiflu",
#  "high cholesterol"=>"lovastatin",
#  "high blood pressure"=>"reserpine",
#  "genital herpes"=>"Valaciclovir",
#  "malaria"=>"quinine", 
#  "hypothroidism"=>"synthroid", 
#  "osteoarthritis"=>"tolmetin",
#  "overactive bladder"=>"oxybutynin",
#  "chest congestion"=>"guaifenesin"
  }
  
=begin  
  [
  	['Bacterial Infection', 'http://dariusroberts.com:4007/images/bacterial_infection_thb.png'],
  	['Chest Congestion', 'http://dariusroberts.com:4007/images/chest_congestion_thb.png'],
  	['Drinky', 'http://dariusroberts.com:4007/images/drinky_thb.png'],
  	['Fever', 'http://dariusroberts.com:4007/images/fever_thb.png'],
  	['Headache', 'http://dariusroberts.com:4007/images/headache_thb.png'],
  	['High Blood Pressure', 'http://dariusroberts.com:4007/images/high_blood_pressure_thb.png'],
  	['High Cholesterol', 'http://dariusroberts.com:4007/images/high_cholesterol_thb.png'],
  	['Hypothroidism', 'http://dariusroberts.com:4007/images/hypothroidism_thb.png'],
  	['Junkie', 'http://dariusroberts.com:4007/images/junkie_thb.png'],
  	['Malaria', 'http://dariusroberts.com:4007/images/malaria_thb.png'],
  	['Obesity', 'http://dariusroberts.com:4007/images/obese.png'],
  	['Osteoarthritis', 'http://dariusroberts.com:4007/images/osteoarthritis_thb.png'],
  	['Vomitous', 'http://dariusroberts.com:4007/images/vomitous_thb.png']
  	]
=end
  
  
  
  def image_ref
    ailments.first.try(:image_ref) || "/images/tropical_hygiene_disease.png"
  end
  
end
