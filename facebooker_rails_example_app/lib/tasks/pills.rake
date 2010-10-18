require 'ruby-debug'

namespace :pills do
  
  desc "hard-cache thumbnails to a filesystem"
  task :import_thumbnails do
    # todo
  end
  
  desc "re-populate pills to the db"
  task :reseed => :environment do
    Pill.delete_all
    
    Rake::Task['pills:seed'].invoke
  end
  
  desc "Add pills to the db"
  task :seed => :environment do

PillboxResource.api_key = "B0FB27B73G"


  # this should really read from fixtures
for ailment, ingredients in {
  "headache"=>  [["aspirin",100,1],
                 ["acetaminophen",100,1]
                ],
  "fever"=>     [["aspirin",100,1],
                 ["acetaminophen",100,1]],
  "bacterial infection"=>[["erythromycin",100,2],
                          ["penicillin",1000,2],
                          ["tetracycline",1000,2]],
  "viral infection"=>[["tamiflu",1000,3],
                      ["Zanamivir",1000,3]],
  "high cholesterol"=>[["lovastatin",100,3],
                        ["rosuvastatin",100,3]],
  "high blood pressure"=>[["reserpine",200,3],
                          ["diltiazem",200,3]], 
  "genital herpes"=>[["Valaciclovir",200,5]],
  "malaria"=>[["quinine",200,4]], 
  "hypothroidism"=>[["synthroid",200,4]], 
  "osteoarthritis"=>[["tolmetin",200,4],
                     ["diclofenac",300,4]], 
  "overactive bladder"=>[["oxybutynin", 300,4]],
  "chest congestion"=>[["guaifenesin",400,4]]
}

for ingredient_attrs in ingredients
  name, cost, level = ingredient_attrs
  
  begin
  
  pr = PillboxResource.find(:first, :params=>{"ingredient"=>name.strip.capitalize}) #rescue nil
  if pr.nil?
    puts "could not find #{name}"
  else
       pill = Pill.find_by_name(name.capitalize)
       next if pill
       
       #else
       Pill.create(
             :cost=>cost,
             :level=>level,
             :image_ref=>pr.image_url,
             :name=>name.capitalize,
             :api_ref=>""
             )
   end
   
   rescue => e
      puts "an error has occured: #{e.name} #{name}"
   end 
  end
end

end
end
