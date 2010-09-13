require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  def test_hometown_when_exists
    location=Facebooker::Location.new(:city=>"Westerville", :state=>"Ohio")
    fm=flexmock(Facebooker::User)
    fm.new_instances.should_receive(:hometown_location).and_return(location)
    mike=users(:mike)
    assert_equal "Westerville Ohio",mike.hometown
  end

  def test_hometown_when_blank
    location=Facebooker::Location.new(:city=>"", :state=>"")
    fm=flexmock(Facebooker::User)
    fm.new_instances.should_receive(:hometown_location).and_return(location)
    mike=users(:mike)
    assert_equal "an undisclosed location",mike.hometown
  end

  def test_attack_creates_attack
    existing_attacks = Attack.count
    users(:jen).attack(users(:mike),moves(:chop))
    assert_equal existing_attacks+1,Attack.count
  end
  
  def test_attack_updates_total_hits_when_a_hit
    jen = users(:jen)
    jen.total_hits=0
    flexmock(Attack).new_instances do |a|
      a.should_receive(:hit? =>true)
    end
    jen.attack(users(:mike),moves(:chop))
    assert_equal 1,jen.total_hits
  end
  
  def test_attack_doesnt_update_total_hits_when_not
    jen = users(:jen)
    jen.total_hits=0
    flexmock(Attack).new_instances do |a|
      a.should_receive(:hit? =>false)
    end
    jen.attack(users(:mike),moves(:chop))
    assert_equal 0,jen.total_hits  
  end
  
  def test_attack_checks_for_belt_when_hit
    jen = users(:jen)
    jen.total_hits=0
    belt=belts(:white)
    flexmock(belt).should_receive(:should_be_upgraded?).once.and_return(false)
    jen.belt=belt
    flexmock(Attack).new_instances do |a|
      a.should_receive(:hit? =>true)
    end
    jen.attack(users(:mike),moves(:chop))
    assert_equal belts(:white),jen.belt
  end
  
  def test_upgrades_belt_when_necessary
    jen = users(:jen)
    jen.total_hits=4
    flexmock(Attack).new_instances do |a|
      a.should_receive(:hit? =>true)
    end
    flexmock(jen).should_receive(:notify_of_new_belt).once
    jen.attack(users(:mike),moves(:chop))
    assert_equal belts(:yellow),jen.belt
  end
  
  def test_for_creates_a_new_user
    e=User.count
    assert_not_nil User.for(2131231)
    assert_equal e+1,User.count
  end
  
  def test_for_returns_an_existing_user
    assert_equal users(:jen),User.for(users(:jen).facebook_id)
  end

  def test_for_sets_session_key_when_creating
    u=User.for(123123,flexmock(:session_key=>"ABC"))
    assert_equal "ABC",u.session_key
  end

  def test_for_updates_session_key
    u=User.for(123123,flexmock(:session_key=>"ABC"))
    u=User.for(123123,flexmock(:session_key=>"DEF"))
    assert_equal "DEF",u.reload.session_key
  end
  
  def test_will_create_facebook_session
    u=User.for(123123,flexmock(:session_key=>"ABC"))
    assert_not_nil u.facebook_session
    assert_equal "ABC",u.facebook_session.session_key
  end

end
