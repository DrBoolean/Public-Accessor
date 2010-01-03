# Include hook code here
require 'public_accessor'
ActiveRecord::Base.extend(RescueRangers::PublicAccessor)
