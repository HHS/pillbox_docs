require File.dirname(__FILE__) + '/../test_helper'

class BeltTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  fixtures :belts
  def test_cant_upgrade_past_last_belt
    assert !Belt.new.should_be_upgraded?(users(:jen))
  end
  
  def test_should_upgrade_if_next_belt_matches
    j=users(:jen)
    j.total_hits = 5
    assert belts(:white).should_be_upgraded?(j)
  end
  
  def test_should_not_upgrade_if_next_belt_needs_more_hits
    j=users(:jen)
    j.total_hits = 4
    assert !belts(:white).should_be_upgraded?(j)
  end
end
