require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FeedsuckerFeed, ' with a valid RSS feed' do
  RSS_FILE_PATH = (File.dirname(__FILE__) + '/../resources/example.rss')

  before(:each) do
    @feed = FeedsuckerFeed.create(
      :title => 'Feedsucker',
      :url => 'http://example.com/feedsucker.rss')
    FakeWeb.register_uri(:get, @feed.url, :body => File.read(RSS_FILE_PATH))
  end

  it "should suck all the posts if no number is given" do
    @feed.suck!
    @feed.posts.size.should == 5
    posts = FeedsuckerFeed.find_by_title(@feed.title).posts
    posts.size.should == 5
    posts.first.title.should == 'Last Post Title' 
    posts.last.title.should == 'First Post Title' 
  end

  it "should suck only the right number of posts" do
    @feed.update_attribute(:number_of_posts, 2)
    @feed.suck!
    FeedsuckerFeed.find_by_title(@feed.title).posts.size.should == 2
    @feed.posts.size.should == @feed.number_of_posts
    @feed.posts.first.title.should == 'Last Post Title' 
  end

  it "should suck all the posts if we ask more posts than the feed has" do
    @feed.update_attribute(:number_of_posts, 12)
    @feed.suck!
    @feed.posts.size.should == 5
  end

  it "should not destroy existing posts with an empty or non standard feed" do
    @feed.suck!
    FakeWeb.register_uri(:get, @feed.url, :body => '<rss></rss>')
    @feed.suck!
    @feed.posts.size.should == 5
  end
end

describe FeedsuckerFeed, ' with an XML feed' do
  XML_FILE_PATH = (File.dirname(__FILE__) + '/../resources/example.xml')

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

  it "should suck all the posts if no number is given" do
    @feed.suck!
    posts = FeedsuckerFeed.find_by_title(@feed.title).posts
    posts.size.should == 5
    posts.first.blog_title.should == 'Last Blog Title' 
    posts.last.blog_title.should == 'First Blog Title' 
    posts.first.title.should == 'Last Post Title' 
    posts.last.title.should == 'First Post Title' 
  end

  it "should suck only the right number of posts" do
    @feed.update_attribute(:number_of_posts, 2)
    @feed.suck!
    FeedsuckerFeed.find_by_title(@feed.title).posts.size.should == 2
    @feed.posts.size.should == @feed.number_of_posts
    @feed.posts.first.title.should == 'Last Post Title' 
  end

  it "should suck all the posts if we ask more posts than the feed has" do
    @feed.update_attribute(:number_of_posts, 12)
    @feed.suck!
    @feed.posts.size.should == 5
  end

  it "should not destroy existing posts with an empty or non standard feed" do
    @feed.suck!
    FakeWeb.register_uri(:get, @feed.url, :body => '<rss></rss>')
    @feed.suck!
    @feed.posts.size.should == 5
  end
end
