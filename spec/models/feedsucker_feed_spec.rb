require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module FeedsuckerMacros
  def self.included(receiver)  
    receiver.extend         ExampleGroupMethods  
  end
  
  module ExampleGroupMethods
    def it_should_suck_all_posts_if_no_number_is_given
      it "should suck all the posts if no number is given" do
        @feed.suck!
        @feed.posts.size.should == 5
        posts = FeedsuckerFeed.find_by_title(@feed.title).posts
        posts.size.should == 5
        posts.first.url.should == 'http://example.com/last-blog/last-post' 
        posts.first.title.should == 'Last Post Title' 
        posts.last.title.should == 'First Post Title'
      end
    end

    def it_should_suck_only_the_right_number_of_posts
      it "should suck only the right number of posts" do
        @feed.update_attribute(:number_of_posts, 2)
        @feed.suck!
        FeedsuckerFeed.find_by_title(@feed.title).posts.size.should == 2
        @feed.posts.size.should == @feed.number_of_posts
        @feed.posts.first.title.should == 'Last Post Title' 
      end
    end
    
    def it_should_suck_all_the_posts_if_we_ask_more_posts_than_the_feed_has
      it "should suck all the posts if we ask more posts than the feed has" do
        @feed.update_attribute(:number_of_posts, 12)
        @feed.suck!
        @feed.posts.size.should == 5
      end
    end

    def it_should_not_destroy_existing_posts_with_an_empty_or_non_standard_feed
      it "should not destroy existing posts with an empty or non standard feed" do
        @feed.suck!
        FakeWeb.register_uri(:get, @feed.url, :body => '<rss></rss>')
        @feed.suck!
        @feed.posts.size.should == 5
      end
    end

    def it_should_not_replace_html_entities
      it "should not replace HTML entities" do
        @feed.suck!
        FakeWeb.register_uri(:get, @feed.url, :body => '<rss></rss>')
        @feed.suck!
        @feed.posts.first.content.include?('&#225;').should be_true
      end
    end
    
    def it_should_not_repeat_old_post_when_not_delete_preview
      it "should_not_repeat_old_post_when_not_delete_preview" do
        @feed.suck!
        @feed.posts.size.should == 5
        @feed.update_attribute(:delete_preview, false)
        @feed.suck!
        @feed.posts.size.should == 5
      end
    end
    
    def it_should_add_new_post_when_not_delete_preview
      it "it_should_add_new_post_when_not_delete_preview" do
        @feed.suck!
        @feed.posts.size.should == 5
        @feed.update_attribute(:delete_preview, false)
        FakeWeb.register_uri(:get, @feed.url, :body => File.read(RSS_FILE_2_PATH)) 
        @feed.suck!
        @feed.posts.size.should == 7
      end
    end
    def it_should_add_new_post_when_not_delete_preview_in_xml
      it "it_should_add_new_post_when_not_delete_preview_in_xml" do
        @feed.suck!
        @feed.posts.size.should == 5
        @feed.update_attribute(:delete_preview, false)
        FakeWeb.register_uri(:get, @feed.url, :body => File.read(XML_FILE_2_PATH)) 
        @feed.suck!
        @feed.posts.size.should == 6
      end
    end
    
  end
end

describe FeedsuckerFeed, ' with a valid RSS feed' do
  include FeedsuckerMacros

  RSS_FILE_PATH = (File.dirname(__FILE__) + '/../resources/example.rss')
  RSS_FILE_2_PATH = (File.dirname(__FILE__) + '/../resources/example_2.rss')
  before(:each) do
    @feed = FeedsuckerFeed.create(
      :title => 'Feedsucker',
      :url => 'http://example.com/feedsucker.rss')
    FakeWeb.register_uri(:get, @feed.url, :body => File.read(RSS_FILE_PATH))
  end

  it_should_suck_all_posts_if_no_number_is_given
  it_should_suck_only_the_right_number_of_posts
  it_should_suck_all_the_posts_if_we_ask_more_posts_than_the_feed_has
  it_should_not_destroy_existing_posts_with_an_empty_or_non_standard_feed
  it_should_not_replace_html_entities
  it_should_not_repeat_old_post_when_not_delete_preview
  it_should_add_new_post_when_not_delete_preview
end

describe FeedsuckerFeed, ' with an XML feed' do
  include FeedsuckerMacros
  
  XML_FILE_PATH = (File.dirname(__FILE__) + '/../resources/example.xml')
  XML_FILE_2_PATH = (File.dirname(__FILE__) + '/../resources/example_2.xml')
  before(:each) do
    @feed = FeedsuckerFeed.create(
      :title => 'Feedsucker',
      :url => 'http://example.com/feedsucker.xml',
      :xpath_blog_title => '//blog-title/text()',
      :xpath_blog_url => '//blog-url/text()',
      :xpath_post_title => '//post-title/text()',
      :xpath_post_url => '//post-url/text()',
      :xpath_post_date => '//post-date/text()',
      :xpath_post_content => '//post-body/text()')
    FakeWeb.register_uri(:get, @feed.url, :body => File.read(XML_FILE_PATH))
  end

  it_should_suck_all_posts_if_no_number_is_given
  it_should_suck_only_the_right_number_of_posts
  it_should_suck_all_the_posts_if_we_ask_more_posts_than_the_feed_has
  it_should_not_destroy_existing_posts_with_an_empty_or_non_standard_feed
  it_should_not_replace_html_entities
  it_should_not_repeat_old_post_when_not_delete_preview
  it_should_add_new_post_when_not_delete_preview_in_xml
end

describe FeedsuckerFeed, 'suck them all!' do
  it 'should suck from all the feeds defined' do
    feed_one, feed_two = mock('feed_one'), mock('feed_two')
    feed_one.should_receive(:suck!)
    feed_two.should_receive(:suck!)
    FeedsuckerFeed.should_receive(:find).with(:all).and_return([feed_one, feed_two])
    FeedsuckerFeed.suck_all!
  end
end
