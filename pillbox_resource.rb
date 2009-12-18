=begin

USAGE

name = 'aspirin'

PillboxResource.api_key = "YOUR SECRET KEY"   
pills = PillboxResource.find(:all, :params=>{"ingredient"=>name.strip.capitalize})
if pills.empty?
  puts "could not find #{name}"
else
  ...
end

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
                  (d,disclaimer), (p,collection) = collection.sort 
                  collection.collect! { |record| instantiate_record(record, prefix_options) }
                end
             end
    end
  end




require 'ruby-debug'

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
  

  cattr_accessor :api_key

  def find(first, options={})
   super first, interpret_params(options)
  end
  def interpret_params(options = {})
    opts = options['params'] || {}
    opts['key'] ||= self.api_key
    
    begin
      opts['color'] = case opts['color']
      when NilClass; 
      when /^[0-9A-Fa-f]+$/;           opts['color'] # valid hex     
      else;                     COLORS[opts['color'].upcase]
      end
    rescue
      # "color not found"
    end

    begin
      opts['shape'] = case opts['shape']
      when NilClass; 
      when /^[0-9A-Fa-f]+$/;          opts['shape'] # valid hex
      else;                     SHAPES[opts['shape'].upcase]
      end
    rescue
      # "shape not found"
    end

    
    opts.delete_if {|k,v| v.nil? }
    options.merge!(opts)
  end

  def shape; attributes['SPLSHAPE'] end 
  def color; attributes['SPLCOLOR'] end 

  def description; attributes['RXSTRING'] end
  def product_code; attributes['PRODUCT_CODE'] end
  def has_image?; attributes['HAS_IMAGE'] == '1' end
  def ingredients; attributes['INGREDIENTS'].split(";") end
  def size; attributes['SPLSIZE'].to_f end
  def image_id; attributes['image_id'] end
  def image_url; image_id ? "http://pillbox.nlm.nih.gov/assets/super_small/#{image_id}ss.png" : nil end
  def imprint; attributes['splimprint'] end

end
