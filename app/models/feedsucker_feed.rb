require 'feed_tools'

class FeedsuckerFeed < ActiveRecord::Base
  has_many :posts, :class_name => 'FeedsuckerPost'
  validates_presence_of :url

  def before_create
    self.number_of_posts ||= 0 # Load all entries/posts by default
  end

  def suck!
    feed = FeedTools::Feed.open(self.url)
    if feed.items.any?
      last_item = self.number_of_posts > 0 ? self.number_of_posts : feed.items.size
      self.posts.destroy_all
      feed.items[0..last_item-1].each do |item|
        self.posts << FeedsuckerPost.create(
          :feedsucker_feed_id => self.id,
          :title   => item.title,
          :content => item.content,
          :date    => item.time,
          :url     => item.link)
      end
    end
  end

  def self.suck_all
    self.find(:all).each {|f| f.suck! }
  end
end
