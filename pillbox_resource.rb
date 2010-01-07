=begin

USAGE
require 'pillbox_resource'

name = 'aspirin'

PillboxResource.api_key = "YOUR SECRET KEY"   
pills = PillboxResource.find(:all, :params=>{"ingredient"=>name})
if pills.empty?
  puts "could not find #{name}"
else
  ...
end


NOTE: shape/color lookup doesn't always work.

>> PillboxResource.find(:all, :params=>{'shape'=>'C48337'})           # GOOD!
>> PillboxResource.find(:first, :params=>{'color'=>"C48324;C48323"})  # WORKS!

>> PillboxResource.find(:all, :params=>{'shape'=>'capsule'})          # BROKERZED
 => NoMethodError: undefined method `name' for nil:NilClass

      

=end



begin
  require 'active_resource'
rescue LoadError
  begin
    require 'rubygems'
    require 'active_resource'
  rescue LoadError
    abort <<-ERROR
The 'activeresource' library could not be loaded. If you have RubyGems 
installed you can install ActiveResource by doing "gem install activeresource".
ERROR
  end
end


# Version check
module Pillbox
  ARES_VERSIONS = ['2.3.4', '2.3.5']
end
require 'active_resource/version'
unless Pillbox::ARES_VERSIONS.include?(ActiveResource::VERSION::STRING)
  abort <<-ERROR
    ActiveResource version #{Pillbox::ARES_VERSIONS.join(' or ')} is required.
  ERROR
end

# Patch ActiveResource
# handle a weird disclaimer message that is in XML
  module ActiveResource
    class Base           
      	    def self.instantiate_collection(collection, prefix_options = {})
                if collection.is_a?(Hash) && collection.size == 1
                  value = collection.values.first
                  if value.is_a?(Array)
                    value.collect! { |record| instantiate_record(record, prefix_options) }
                  else
                    [ instantiate_record(value, prefix_options) ]
                  end
                else                  
                  # strip extra layer off the front end (a disclaimer)
                  (d,disclaimer), (p,collection) = collection.sort 
                  
                  # ensure type Array
                  collection = collection.is_a?(Array) ? collection : Array[collection]
                  
                  collection.collect! { |record| instantiate_record(record, prefix_options) }
                end
             end
    end
  end



class PillboxResource < ActiveResource::Base
  self.site = "http://pillbox.nlm.nih.gov/PHP/pillboxAPIService.php"

  SHAPES = {
      'BULLET'=> 'C48335',
      'CAPSULE'=> 'C48336',
      'CLOVER'=> 'C48337',
      'DIAMOND'=> 'C48338',
      'DOUBLE_CIRCLE'=> 'C48339',
      'FREEFORM'=> 'C48340',
      'GEAR'=> 'C48341',
      'HEPTAGON'=> 'C48342',
      'HEXAGON'=> 'C48343',
      'OCTAGON'=> 'C48344',
      'OVAL'=> 'C48345',
      'PENTAGON'=> 'C48346',
      'RECTANGLE'=> 'C48347',
      'ROUND'=> 'C48348',
      'SEMI_CIRCLE'=> 'C48349',
      'SQUARE'=> 'C48350',
      'TEAR'=> 'C48351',
      'TRAPEZOID'=> 'C48352',
      'TRIANGLE'=> 'C48353'
  }
  SHAPE_CODES = SHAPES.invert

  COLORS = {
      'BLACK'=> 'C48323',
      'BLUE'=> 'C48333',
      'BROWN'=> 'C48332',
      'GRAY'=> 'C48324',
      'GREEN'=> 'C48329',
      'ORANGE'=> 'C48331',
      'PINK'=> 'C48328',
      'PURPLE'=> 'C48327',
      'RED'=> 'C48326',
      'TURQUOISE'=> 'C48334',
      'WHITE'=> 'C48325',
      'YELLOW'=> 'C48330'
  }
  COLOR_CODES = COLORS.invert
  

  cattr_accessor :api_key

  def self.find(first, options={})
    validate_presence_of_api_key 
    validate_pillbox_api_params(options)
    super first, self.interpret_params(options)
  end
  def self.interpret_params(options = {})
    params = options['params'] || {}
    params['key'] ||= self.api_key
    
    begin
      params['color'] = case params['color']
      when NilClass; 
      when Array;                          params['color'].join(";")
      when /^(\d|[a-f]|[A-F])+/;           params['color'] # valid hex     
      else;                         COLORS[params['color'].upcase]
      end
    rescue
      # "color not found"
    end
    
    begin
      params['shape'] = case params['shape']
      when NilClass; 
      when Array;                         params['color'].join(";")  
      when /^(\d|[a-f]|[A-F])+/;          params['shape'] # valid hex
      else;                        SHAPES[params['shape'].upcase]
      end
    rescue # NoMethodError => e
      # raise X if e.match "shape not found"
    end

    # todo: prodcode
    
    params.delete_if {|k,v| v.nil? }
    options.merge!(params)
  end
  
  def self.validate_presence_of_api_key
    raise "must define api key. PillboxResource.api_key = 'YOUR SECRET KEY'" unless self.api_key
  end
  
  VALID_ATTRIBUTE_NAMES = %w(color ingredient shape imprint prodcode has_image size) 
  def self.validate_pillbox_api_params(options)
    raise "try using find :all, :params => { ... }  with one of these options: #{VALID_ATTRIBUTE_NAMES.inspect}" unless options[:params].is_a?(Hash)
    raise "valid params options are:  #{VALID_ATTRIBUTE_NAMES.inspect}  ... you have invalid params option(s): #{(VALID_ATTRIBUTE_NAMES && options[:params].keys) - VALID_ATTRIBUTE_NAMES}" unless ((VALID_ATTRIBUTE_NAMES && options[:params].keys) - VALID_ATTRIBUTE_NAMES).empty?
    
  end

  def shape # handle multi-color (OUTPUT ONLY)
    return nil unless attributes['SPLSHAPE']
    attributes['SPLSHAPE'].split(";").map do |shape_code|
      SHAPE_CODES[shape_code] || shape_code
    end
  end 
  def color
    return nil unless attributes['SPLCOLOR']
    attributes['SPLCOLOR'].split(";").map do |color_code|
      COLOR_CODES[color_code] || color_code
    end
  end 

  def description; attributes['RXSTRING'] end
  def prodcode; attributes['PRODUCT_CODE'] end
  def product_code; attributes['PRODUCT_CODE'] end
  def has_image?; attributes['HAS_IMAGE'] == '1' end
  def ingredients; attributes['INGREDIENTS'].split(";") end
  def size; attributes['SPLSIZE'].to_f end
  def image_id; attributes['image_id'] end
  def image_url(image_size = 'super_small')
    unless image_id 
      return nil
    end
    case image_size
      when "super_small"; "http://pillbox.nlm.nih.gov/assets/super_small/#{image_id}ss.png" 
      when "small";       "http://pillbox.nlm.nih.gov/assets/small/#{image_id}sm.jpg" 
    end
  end
  def imprint; attributes['splimprint'] end

end
