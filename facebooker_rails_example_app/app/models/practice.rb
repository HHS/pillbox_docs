class Practice < ActiveRecord::Base
  # START:ASSOCIATIONS
  belongs_to :next_practice, :class_name=>"Practice", :foreign_key=>:next_practice_id
  # END:ASSOCIATIONS

  # START:INITIAL_BELT
  def self.initial_practice
    find_by_level(1)
  end
  # END:INITIAL_BELT
  
  # START:SHOULD_BE_UPGRADED
  def should_be_upgraded?(user)
    !next_practice.nil? and user.total_hits >= next_practice.minimum_hits 
  end
	# END:SHOULD_BE_UPGRADED
	
end
