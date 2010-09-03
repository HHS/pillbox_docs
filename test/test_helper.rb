# -*- encoding: utf-8 -*-
$:.unshift File.dirname(File.dirname(__FILE__))
require 'test/unit'
require 'pillbox'

class Test::Unit::TestCase
  
  def load_yaml_fixture(path = all_meds.yml)
    absolute_path = File.join(File.dirname(__FILE__), "fixtures", path)
    YAML::load_file absolute_path
  end
  
  def deny(*args)
    args.each { |arg| assert !arg }
  end
end