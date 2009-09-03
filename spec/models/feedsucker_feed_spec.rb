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
    posts = FeedsuckerFeed.find_by_title(@feed.title).posts
    posts.size.should == 5
    @feed.posts.first.title == 'Latest post title' 
    @feed.posts.last.title == 'First post title' 
  end

  it "should suck only the right number of posts" do
    @feed.update_attribute(:number_of_posts, 2)
    @feed.suck!
    FeedsuckerFeed.find_by_title(@feed.title).posts.size.should == 2
    @feed.posts.size.should == @feed.number_of_posts
    @feed.posts.first.title == 'Latest post title' 
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
