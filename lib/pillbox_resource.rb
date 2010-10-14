# -*- encoding: utf-8 -*-
=begin

NOTE: This library utilizes version 2 of the Pillbox API, published 10/9/10.

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
=end

# Version check
module Pillbox
  ARES_VERSIONS = ['2.3.4', '2.3.5', '3.0.0']
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
        (d,disclaimer), (p,collection), (r,@record_count) = collection.sort

        puts "\nMatched #{@record_count} records...\n"

        # ensure array
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
  def self.shapes; SHAPES.inject({}){|i,(k,v)| i.merge k.humanize => v } end

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
  def self.colors; COLORS.inject({}){|i,(k,v)| i.merge k.humanize => v } end
  
  DEA_CODES = {
      'I'   => 'C48672',
      'II'  => 'C48675',
      'III' => 'C48676',
      'IV'  => 'C48677',
      'V'   => 'C48679'
  }
  SCHEDULE_CODES = DEA_CODES.invert
  def self.dea_codes; DEA_CODES.inject({}) { |i,(k,v)| i.merge k.humanize => v } end

  cattr_accessor :api_key
  attr_accessor :color2
  
  def self.record_count
    @record_count.to_i
  end
  
  def self.test!
    "Using testing api_key" if self.api_key = load_test_key
  end

  def self.find(first, options={})
    # MYTODO :| ok for now... but this only works with rails
    options = HashWithIndifferentAccess.new(options)
    validate_pillbox_api_params(options)
    begin
      super first, self.interpret_params(options)
    rescue REXML::ParseException => e
      # Work around no XML returned when no records are found.
      if e.message =~ /The document "No records found" does not have a valid root/
        STDERR.puts "No records found."
      else
        raise
      end
    end
  end
  
  def respond_to?(meth)
    (attributes.has_key?(meth.to_s.upcase) || attributes.has_key?(meth.to_s)) ? true : super
  end
  
  def method_missing(method, *args, &block)
    if attributes.has_key?(method.to_s.upcase)
      attributes[method.to_s.upcase].nil? ? [] : attributes[method.to_s.upcase]
    elsif attributes.has_key?(method.to_s)
      attributes[method.to_s].nil? ? [] : attributes[method.to_s]
    else
      super
    end
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

  def prodcode; attributes['PRODUCT_CODE'] end
  def info_url; "http://druginfo.nlm.nih.gov/drugportal/dpdirect.jsp?name="+ingredient end
  def has_image?; attributes['HAS_IMAGE'] == '1' end
  def ingredient; self.ingredients end
  def size; attributes['SPLSIZE'].to_f end
  def score; attributes['SPLSCORE'] end
  def imprint; attributes['splimprint'] end
  def trade_name; self.rxstring.split(" ").first.downcase end

  def image_url(image_size = 'super_small')
    unless image_id 
      return nil
    end
    case image_size
      when "super_small"; "http://pillbox.nlm.nih.gov/assets/super_small/#{image_id}ss.png" 
      when "small";       "http://pillbox.nlm.nih.gov/assets/small/#{image_id}sm.jpg" 
      when "medium";      "http://pillbox.nlm.nih.gov/assets/medium/#{image_id}md.jpg"
      when "large";       "http://pillbox.nlm.nih.gov/assets/large/#{image_id}lg.jpg"
    end
  end
  
  def dea
    return nil unless attributes['DEA_SCHEDULE_CODE']
    "Schedule #{SCHEDULE_CODES[attributes['DEA_SCHEDULE_CODE'].to_s]}" 
  end
  
  def inactive
    # Remove double quotes from the inactive ingredients list
    Array(attributes['SPL_INACTIVE_ING'].split("/")).map { |str| str.gsub('"', ' ').strip}
  end
  
  def author
    # Remove double quotes from the author attribute
    attributes['AUTHOR'].gsub('"', ' ').strip
  end

private
  def self.load_test_key
    test_key = YAML.load_file("#{File.expand_path(File.dirname(__FILE__) + '/../test/fixtures/test_api_key.yml')}")
    test_key[:key]
  end
  
  VALID_ATTRIBUTE_NAMES = %w(color score ingredient ingredients inactive dea author shape imprint prodcode has_image size lower_limit product_code)

  def self.validate_pillbox_api_params(options)
    validate_presence_of_api_key(options)
    raise "try using find :all, :params => { ... }  with one of these options: #{VALID_ATTRIBUTE_NAMES.inspect}" unless options[:params].is_a?(Hash)
    raise "valid params options are:  #{VALID_ATTRIBUTE_NAMES.inspect}  ... you have invalid params option(s): #{(VALID_ATTRIBUTE_NAMES && options[:params].keys) - VALID_ATTRIBUTE_NAMES}" unless ((VALID_ATTRIBUTE_NAMES && options[:params].keys) - VALID_ATTRIBUTE_NAMES).empty?
  end
  
  def self.validate_presence_of_api_key(options)
    raise "You must define api key. PillboxResource.api_key = 'YOUR SECRET KEY'" unless (self.api_key or options[:params][:key])
  end
  
  def self.interpret_params(options = {})
    # puts options
    @params = HashWithIndifferentAccess.new(options['params']) || {}
    @params['key'] ||= self.api_key
    
    # flex api is crude... this makes it compatible with rails active_resource and will_paginate
    if @params[:start]
       @params['lower_limit'] = (@params[:page] || "0").to_i * @params[:start].to_i
    end
    @params.delete(:page)
    @params.delete(:start)
    
    %w(color shape prodcode dea ingredient).each do |param|
      self.send("parse_#{param}".to_sym) if @params[param]
    end
  
    @params.delete_if {|k,v| v.nil? }
    options['params'].merge!(@params)
        puts options
    return options
  end
  
  def self.parse_color
    begin
      @params['color'] = case @params['color']
      when NilClass; 
      when Array;                 @params['color'].join(";")
      when /^(\d|[a-f]|[A-F])+/;  @params['color'] # valid hex     
      else;                       COLORS[@params['color'].upcase]
      end
    rescue
      # "color not found"
    end
  end
  
  def self.parse_shape
    begin
      @params['shape'] = case @params['shape']
      when NilClass; 
      when Array;               @params['shape'].join(";")  
      when /^([Cc]{1}\d{5})+/;  @params['shape'] # valid hex
      else
        SHAPES[@params['shape'].upcase]
      end
    rescue # NoMethodError => e
      # raise X if e.match "shape not found"
    end
  end
  
  def self.parse_prodcode
    # todo: prodcode
    begin
      @params['product_code'] = case @params['product_code']
      # when nil;                puts "i can see my house!  "#raise "Product code cannot be nil" # Schema says PRODUCT_CODE cannot be NULL
      # when Array;                   params['product_code'].join(";")
      when /\A(\d{3,}-\d{3,4})\z/;  @params['product_code']
      else;
      end
    rescue
    end
  end
  
  def self.parse_dea
    begin
      @params['dea'] = case @params['dea']
      when NilClass;
      when /^([Cc]{1}\d{5})+/;  @params['dea'] # valid hex
      when /\AI{1,3}\z|\AIV\z|\AV\z/; DEA_CODES[@params['dea']]
      else
        raise "Invalid schedule code.  Must be one of [I, II, III, IV, V]."
      end
    rescue
      # raise "DEA schedule not found"
    end
  end
  
  def self.parse_ingredient
    begin
      @params['ingredient'] = case @params['ingredient']
      when NilClass;
      when Array; @params['ingredient'].sort.join("; ") # Need to sort alphabetically before send and need a space after semicolon
      when /AND/
        raise "not implemented"
        # Add some parsing to concatenate terms appropriately
      when /OR/
        raise "not implemented"
        # Add some parsing to create two queries, run them, and then merge the results and return it
      else
        # raise "Ingredients not found."
      end
    rescue
      # raise "Ingredient has an invalid format."
    end
  end
end

=begin
ONE-LINERS
PillboxResource.api_key = CHANGE_ME_TO_A_VALID_KEY

resources = Pill.all(:conditions=>"image_ref is NULL").map(&:name).map{|name| begin PillboxResource.find(:first, :params=>{:has_image=>'1', 'ingredient'=>name.downcase}) rescue name end}; true
resources = Pill.all.map(&:name).map{|name| begin PillboxResource.find(:first, :params=>{:has_image=>'1', 'ingredient'=>name.downcase}) rescue name end}; true

resources.map(&:to_s)
#=> ["#<PillboxResource:0x2114ea8>", "Imodium", "Penicillin", "Placebo", "Tamiflu", "#<PillboxResource:0x2073044>", "#<PillboxResource:0x2045b08>", "#<PillboxResource:0x2566664>", "Z-Pak", "#<PillboxResource:0x2503fdc>", "#<PillboxResource:0x2489124>", "#<PillboxResource:0x242d770>", "Ex-Lax", "Orlisat"]

to_be_filled_out = resources.dup
to_be_filled_out = to_be_filled_out.reject{|r| r.is_a?(String) }
to_be_filled_out = to_be_filled_out.reject{|r| r.nil? }
#to_be_filled_out = to_be_filled_out.reject{|r| r.image_ref.is_a?(String) } # already?

#execute
# all pills
Pill.all.each {|pill|
    pr = begin
          PillboxResource.find(:first, :params=>{:has_image=>'1', 'prodcode'=>pill.prodcode})
        rescue
        end
    pr ||= begin 
            PillboxResource.find(:first, :params=>{:has_image=>'1', 'ingredient'=>pill.name.downcase})
        rescue
            next            
        end
    pill.update_attributes :image_ref => pr.image_url('small'),
                           :api_ref => pr.api_url,
                           :accepted_names => [pr.ingredient, pr.trade_name]
}
# Pill.all(:conditions=>'accepted_names is NULL').map(&:name)


resources = Pill.all.map{|pill| 
   begin 
    r = PillboxResource.find(:first, :params=>{:has_image=>'1', 'ingredient'=>pill.name.downcase})  
    pill.update_attributes(
     :image_ref => r.image_url,
     :api_ref => r.api_url,
     :accepted_names => [r.ingredient, r.trade_name]
     )
   rescue 
     pill.name 
    end
}; true


#from names
to_be_filled_out.map {|r| 
  p = Pill.find_by_name(r.trade_name); 
  if p.nil?
    puts "could not find #{r.trade_name}"
  else 
    begin
      p.update_attributes(
       :image_ref => r.image_url,
       :api_ref => r.api_url,
       :accepted_names => [r.ingredient, r.trade_name]
       )
     rescue => e
       puts "pill #{r.trade_name} not updated because: #{e}"
     end

  end
}; true

# parse out of a messy file
counter = 1
names = {}
Dir.glob('drugnames/*.txt').map {|path| f = File.open(path, "r") {|file|
 while (line = file.gets)                                              
   counter = counter + 1
   names[path] ||= []
   names[path] << line.gsub(","," ").split(" ").first
 end
 puts "Searched #{counter} lines for pill names at the beginning of the line"
}}
names
pill_resources = []
found_names = []
names.each {|k,group_names|
 for name in group_names.uniq
   begin
     result = PillboxResource.find(:first, :params=>{:has_image=>'1', 'ingredient'=>name.downcase})
     if result.nil?
       puts "no images found for #{name}"
     else
       pill_resources << result
       found_names << name
     end
   rescue
     puts "could not find #{name}"
   end
  end
}
puts "DID find images of the following, stored in 'pill_resources' variable" unless pill_resources.empty?
for name in found_names
  puts name
end

pill_category = nil #PillCategory.find_by_title("Sexual Health")
for pill_name in ["","",""]
  Pill.create(:name=>pill_name, :pill_category=>pill_category)
end

=end
