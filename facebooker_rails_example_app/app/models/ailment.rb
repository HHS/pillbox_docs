class Ailment < ActiveRecord::Base
  belongs_to :pill
  belongs_to :patient
  
  def image_ref
    name.downcase.gsub(" ","_") + ".png"
  end  
  
end
