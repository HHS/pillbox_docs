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
                  instantiate_record(collection.values.last.first, prefix_options)
#                  collection.collect! { |record| instantiate_record(record, prefix_options) }
                end
             end
    end
  end






class PillboxResource < ActiveResource::Base
  self.site = "http://pillbox.nlm.nih.gov/PHP/pillboxAPIService.php"

#  def find(first, *args, options ={})
#   # interpret options
#   super
#  end

  def shape; attributes['SPLSHAPE'] end 
  def color; attributes['SPLCOLOR'] end 

  def description; attributes['RXSTRING'] end
  def product_code; attributes['PRODUCT_CODE'] end
  def has_image?; attributes['HAS_IMAGE'] == '1' end
  def ingredients; attributes['INGREDIENTS'].split(";") end
  def size; attributes['SPLSIZE'].to_i end
  def image_id; attributes['image_id'] end
  def image_url; image_id ? "http://pillbox.nlm.nih.gov/assets/super_small/#{image_id}ss.png" : nil end
  def imprint; attributes['splimprint'] end

end
