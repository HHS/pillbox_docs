# -*- encoding: utf-8 -*-
require 'test_helper'

class PillboxResourceTest < Test::Unit::TestCase
  
  def setup
    # @meds = load_yaml_fixture
    PillboxResource.test!
  end
  
  def test_should_find_by_combo_shape
    med = PillboxResource.first(:params=>{'color'=>"C48324;C48323"})
    assert_equal("Acetaminophen 150 MG / Aspirin 180 MG / Codeine 30 MG Oral Capsule", med.rxstring)
  end
  
  def test_should_accept_shape_as_hex
    meds = PillboxResource.all(:params=>{'shape' => 'C48336'})
    assert_equal(2345, PillboxResource.record_count)
  end
  
  def test_should_accept_color_as_hex
    meds = PillboxResource.all(:params => {'color' => "C48328"})
    assert_equal(886, PillboxResource.record_count)
  end
  
  def test_should_accept_multiple_colors
    meds = PillboxResource.all(:params => { 'color' => ['C48328', 'C48327']})
    assert_equal(1, meds.count)
    assert_equal('Selfemra 20 MG Oral Capsule', meds.first.rxstring)
  end
  
  def test_should_accept_shape_as_string
    meds = PillboxResource.all(:params => {'shape' => 'capsule'})
    assert_equal(2345, PillboxResource.record_count)
    meds.each { |m| assert_equal('capsule', m.shape.kind_of?(Array) ? m.shape.first.downcase : m.shape.downcase) }
  end
  
  def test_should_accept_color_as_string
    meds = PillboxResource.all(:params => {'color' => 'white'})
    assert_equal(4364, PillboxResource.record_count)
  end
  
  def test_param_combinations_should_work
    meds = PillboxResource.all(:params => {'shape' => 'C48348', 'color' => 'C48325'})
    assert_equal(2401, PillboxResource.record_count)
  end
  
  def test_imprint_search_should_work
    meds = PillboxResource.all(:params => {'imprint' => 'NVR'})
    assert_equal(69, PillboxResource.record_count)
  end
  
  def test_size_search_should_work
    meds = PillboxResource.all(:params => {'size' => '12.00'})
    assert_equal(3082, PillboxResource.record_count)
  end
  
  def test_should_return_normalized_array_of_strings_for_inactive_ingredients
    meds = PillboxResource.all(:params => {:has_image => true})
    assert_equal(Array, meds.first.inactive.class)
    meds.first.inactive.each do |ing|
      assert_no_match(/\s$/, ing)
      assert_no_match(/^\s/, ing)
    end
    assert_equal("SILICON DIOXIDE", meds.first.inactive[1])
  end
  
  def test_should_return_appropriate_dea_schedule
    med = PillboxResource.first(:params => {:ingredient => 'Hydromorphone'})
    assert_equal('Schedule II', med.dea)
  end
  
  def test_should_rescue_rexml_parser_error
    assert_nothing_raised { med = PillboxResource.all(:params => {:dea => "a"} ) }
  end
  
  def test_should_allow_searching_for_multiple_active_ingredients
    med = PillboxResource.all(:params => {:ingredient => ['amlodipine', 'benazepril']})
    assert_equal(28, med.count)
    med = PillboxResource.all(:params => {:ingredient => ['valsartan','hydrochlorothiazide', 'amlodipine']})
    assert_not_nil(med)
    assert_equal(5, med.count)
  end
  
  def test_should_return_a_valid_image_url
    meds = PillboxResource.all(:params => {:has_image => 1})
    meds.each { |m| assert_equal("http://pillbox.nlm.nih.gov/assets/super_small/#{m.image_id}ss.png", m.image_url)}
  end
  
  def test_should_return_an_array_of_valid_urls
    meds = PillboxResource.all(:params => {:has_image => 1})
    meds.each do |m| 
      assert_equal(["http://pillbox.nlm.nih.gov/assets/super_small/#{m.image_id}ss.png",
                                  "http://pillbox.nlm.nih.gov/assets/small/#{m.image_id}sm.jpg",
                                  "http://pillbox.nlm.nih.gov/assets/medium/#{m.image_id}md.jpg",
                                  "http://pillbox.nlm.nih.gov/assets/large/#{m.image_id}lg.jpg"], m.image_url('all'))
    end
  end
  
  def test_should_return_a_valid_trade_name
    med = PillboxResource.first(:params => {:ingredient  => 'Sildenafil'})
    assert_equal('Viagra', med.trade_name)
  end
end