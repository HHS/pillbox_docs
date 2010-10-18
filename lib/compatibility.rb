module Compatibility
  module ClassMethods
    def first(options = {})
      find(:first, options)
    end
    
    def all(options = {})
      find(:all, options)
    end
  end
  
  def self.included(base)
    base.extend(ClassMethods)
  end
end