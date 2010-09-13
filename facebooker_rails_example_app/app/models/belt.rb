class Belt < ActiveRecord::Base
  # START:ASSOCIATIONS
  belongs_to :next_belt, :class_name=>"Belt", :foreign_key=>:next_belt_id
  # END:ASSOCIATIONS

  # START:INITIAL_BELT
  def self.initial_belt
    find_by_level(1)
  end
  # END:INITIAL_BELT
  
  # START:SHOULD_BE_UPGRADED
  def should_be_upgraded?(user)
    !next_belt.nil? and user.total_hits >= next_belt.minimum_hits 
  end
	# END:SHOULD_BE_UPGRADED
	
end
