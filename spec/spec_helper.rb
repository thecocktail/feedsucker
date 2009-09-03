begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'  
  require 'fakeweb'
rescue LoadError  
  puts "You need to install rspec in your base app and the fakeweb gem in order to run the plugin specs"
  exit  
end

