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
  
  def test_should_return_normalized_array_of_strings_for_inactive_ingredients
    meds = PillboxResource.find(:all, :params => {:has_image => true})
    assert_equal(Array, meds.first.inactive.class)
    meds.first.inactive.each do |ing|
      assert_no_match(/\s$/, ing)
      assert_no_match(/^\s/, ing)
    end
    assert_equal("SILICON DIOXIDE", meds.first.inactive[1])
  end
  
  def test_should_return_appropriate_dea_schedule
    med = PillboxResource.find(:first, :params => {:ingredient => 'Hydromorphone'})
    assert_equal('Schedule II', med.dea)
  end
  
  def test_should_rescue_rexml_parser_error
    assert_nothing_raised { med = PillboxResource.find(:all, :params => {:dea => "a"} ) }
  end
  
  def test_should_allow_searching_for_multiple_active_ingredients
    med = PillboxResource.find(:all, :params => {:ingredient => ['amlodipine', 'benazepril']})
    assert_equal(28, med.count)
    med = PillboxResource.find(:all, :params => {:ingredient => ['valsartan','hydrochlorothiazide', 'amlodipine']})
    assert_not_nil(med)
    assert_equal(5, med.count)
  end
end