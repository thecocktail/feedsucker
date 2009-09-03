class FeedsuckerPost < ActiveRecord::Base
  belongs_to :feed, :class_name => 'FeedsuckerFeed', :foreign_key => 'feedsucker_feed_id'
  validates_presence_of :feed
end
