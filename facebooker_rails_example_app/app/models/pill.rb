class Pill < ActiveRecord::Base
  before_create :set_rep_to_level
  named_scope :leveled, lambda { |lev| { :conditions => ["level = ?", lev] } }
  named_scope :leveled_for, lambda { |acct| # or caregiver
              cg = acct.is_a?(Caregiver) ? acct : acct.caregiver
              { :conditions => ["level <= ?", cg.level] } }
  
  has_many :ailments # that it cures
  serialize :messages, Array
  serialize :accepted_names, Array
  attr_accessor :preset_messages
  belongs_to :pill_category

  def image_name; image_ref end
  def image_ref(image_size = 'super_small')
    unless image_id 
      return nil
    end
    case image_size.to_s
      when "super_small"; "http://pillbox.nlm.nih.gov/assets/super_small/%06dss.png" % image_id
      when "small";       "http://pillbox.nlm.nih.gov/assets/small/%06dsm.jpg"       % image_id
      when "medium";       "http://pillbox.nlm.nih.gov/assets/medium/%06dmd.jpg"     % image_id
      when "large";       "http://pillbox.nlm.nih.gov/assets/large/%06dlg.jpg"       % image_id
    end
  end
  
  def to_s
    name
  end

  extend ActiveSupport::Memoizable
  def get_searchable_attributes
    PillboxResource.api_key = 'B0FB27B73G'      
    pill_resource = PillboxResource.find(:first, :params=>{:prodcode=>prodcode})
    pill_resource.searchable_attribute.except('ingredient')
  end
  memoize :get_searchable_attributes
  
  def set_rep_to_level
    self.level ||= 1
    self.reputation = self.level * 10
  end
  def cost
    self['cost'] || 10
  end
  
  def preset_messages
    self['messages'] || ["hey sexy", "Try one. You'll like it! :)", "Take one daily"]    
  end
  def build_message
    Message.new(:pill=>self)
  end
  
end
