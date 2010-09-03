# -*- encoding: utf-8 -*-
require 'test_helper'

class PillboxResourceTest < Test::Unit::TestCase
  
  def setup
    # @meds = load_yaml_fixture
    PillboxResource.test!
  end
  
  def test_truth
    assert true
  end
  
  def test_should_accept_shape_as_hex
    meds = PillboxResource.find(:all, :params=>{'shape' => 'C48336'})
    # puts PillboxResource.instance_eval { puts params }
    assert_equal(201, meds.count)
  end
  
  def test_should_accept_shape_as_string
    meds = PillboxResource.find(:all, :params => {'shape' => 'capsule'})
    assert_equal(201, meds.count)
  end
end