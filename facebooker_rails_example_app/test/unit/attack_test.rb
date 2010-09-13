require File.dirname(__FILE__) + '/../test_helper'

class AttackTest < ActiveSupport::TestCase

  fixtures :users, :moves  
  def setup
    @attack = Attack.new(:attacking_user=>users(:jen),
                        :defending_user=>users(:mike),
                        :move=>moves(:chop))
  end

  def test_valid
    assert @attack.valid?
  end

  def test_attack_requires_attacking_user
    @attack.attacking_user=nil
    assert !@attack.valid?
  end

  def test_attack_requires_defending_user
    @attack.defending_user=nil
    assert !@attack.valid?
  end

  def test_attack_requires_move
    @attack.move=nil
    assert !@attack.valid?
  end

end
