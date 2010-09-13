# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # START:NAME
  def name(user,options={})
    fb_name(user,
      {:ifcantsee=>(user.nickname||"a pill-popping doctor")}.merge(options))
  end
  
  def external_name(user)
    user.nickname || "some maniac with a medical license"
  end
    
  # END:NAME
  
  def message_result(message)
    message.hit? ? "cured" : "deteriorated"
  end


  def patients_path? 
    controller.params[:controller] == 'patients'
  end
  
  
  def money(val)
    Currency.Money(val, :USD).format.split("\.")[0]
  end
  
end
