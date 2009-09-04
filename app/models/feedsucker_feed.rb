require 'feed_tools'
require 'rexml/document'
require 'net/http'

class FeedsuckerFeed < ActiveRecord::Base
  has_many :posts, :class_name => 'FeedsuckerPost'
  validates_presence_of :url

  def before_create
    self.number_of_posts ||= 0 # Load all entries/posts by default
  end

  def suck!
    items = self.xpath_post_url ? xml_feed_items : rss_or_atom_feed_items
    if items.any?
      last_item = self.number_of_posts > 0 ? self.number_of_posts : items.size
      self.posts.destroy_all
      items[0..last_item-1].each do |item|
        self.posts << FeedsuckerPost.create(
          :feedsucker_feed_id => self.id,
          :blog_title => item[:blog_title],
          :blog_url   => item[:blog_url],
          :title      => item[:post_title],
          :content    => item[:post_content],
          :date       => item[:post_date],
          :url        => item[:post_link])
      end
    end
  end

  def self.suck_all!
    self.find(:all).each {|feed| feed.suck!}
  end

  private
    def rss_or_atom_feed_items
      FeedTools::Feed.open(self.url).items.inject([]) do |items, item|
        items << {
          :post_title   => item.title,
          :post_content => item.content,
          :post_date    => item.time,
          :post_url     => item.link
        }
      end
    end

    def xml_feed_items
      xmldata = Net::HTTP.get_response(URI.parse(self.url)).body
      xmldoc = REXML::Document.new(xmldata)
      items = REXML::XPath.match(xmldoc, self.xpath_post_url).map {|url| {:post_url => url}}
      %w{post_title post_content post_date
         blog_title blog_url}.each do |suffix|
        REXML::XPath.match(xmldoc, self.send("xpath_#{suffix}")).each_with_index do |value, index|
          items[index][suffix.to_sym] = value.to_s
        end
      end
      items
    end
end
