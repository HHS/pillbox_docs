module PatientsHelper
  def illnesses_js_array
    Patient::TREATMENTS.map{|disease, pill| Array[disease, image_path("icons/#{disease.underscore.gsub(" ","_")}.png")] }.to_json
  end
  def random_names(num)
    (1..num).map{ Faker::Name.name }.to_json
  end
end
