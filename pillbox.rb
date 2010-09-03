# -*- encoding: utf-8 -*-
$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
begin
  require 'active_resource'
  require 'pillbox_resource'
rescue LoadError
  begin
    require 'rubygems'
    require 'active_resource'
    require 'pillbox_resource'
  rescue LoadError
    abort <<-ERROR
The 'activeresource' or 'pillbox_resource' library could not be loaded. If you have RubyGems 
installed you can install ActiveResource by doing "gem install activeresource".  If ActiveResource is installed
you may need to change your path to allow PillboxResource to load.
ERROR
  end
end