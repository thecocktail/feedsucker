require 'rexml/document'
require 'net/http'

class FeedsuckerFeed < ActiveRecord::Base
  has_many :posts, :class_name => 'FeedsuckerPost'
  validates_presence_of :url

  def before_create
    self.number_of_posts ||= 0 # Load all entries/posts by default
  end

  def suck!
    #items = self.xpath_post_url ? xml_feed_items : rss_or_atom_feed_items
    items = xml_feed_items
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
          :url        => item[:post_url])
      end
    end
  end

  def self.suck_all!
    self.find(:all).each {|feed| feed.suck!}
  end

  private
    def xml_feed_items
      xmldata = Net::HTTP.get_response(URI.parse(self.url)).body
      xmldoc = REXML::Document.new(xmldata)
      xpath_defaults = xpath_defaults_for(xmldoc)
      xpath = self.xpath_post_url || xpath_defaults[:post_url]
      items = REXML::XPath.match(xmldoc, xpath).map {|url| {:post_url => url.to_s}}
      %w{post_title post_content post_date
         blog_title blog_url}.each do |suffix|
        xpath = self.send("xpath_#{suffix}") || xpath_defaults[suffix.to_sym]
        REXML::XPath.match(xmldoc, xpath).each_with_index do |value, index|
          items[index][suffix.to_sym] = value.to_s
        end
      end
      items
    end

    def xpath_defaults_for(xmldoc)
      # TODO: xpaths if xmldoc is an Atom feed
      { :blog_title => '//channel/title/text()',
        :blog_url => '//channel/link/text()',
        :post_title => '//item/title/text()',
        :post_url => '//item/link/text()',
        :post_date => '//item/pubDate/text()',
        :post_content => '//item/description/text()' }
    end
end
