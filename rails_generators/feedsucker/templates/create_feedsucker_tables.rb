class CreateFeedsuckerTables < ActiveRecord::Migration
  def self.up
    create_table :feedsucker_feeds do |t|
      t.string :title
      t.string :nicetitle
      t.string :url
      t.integer :number_of_posts
      t.string :xpath_blog_title
      t.string :xpath_blog_url
      t.string :xpath_post_title
      t.string :xpath_post_content
      t.string :xpath_post_date
      t.string :xpath_post_url

      t.timestamps
    end
    create_table :feedsucker_posts do |t|
      t.integer :feedsucker_feed_id
      t.string :blog_title
      t.string :blog_url
      t.string :title
      t.text :content
      t.datetime :date
      t.string :url

      t.timestamps
    end
    # Feedsucker Feeds examples:
    # ==========================
    # FeedsuckerFeed.create(
    #   :title => 'RSS/Atom example',
    #   :nicetitle => 'atom-example',
    #   :number_of_posts => 3, # optional (all posts in feed if blank)
    #   :url => 'http://example.com/posts.atom')
    # FeedsuckerFeed.create(
    #   :title => 'XML resource index example',
    #   :nicetitle => 'xml-example',
    #   :url => 'http://example.com/temas/arte-y-arquitectura/xml',
    #   :number_of_posts => 3, # optional (all posts if blank)
    #   :xpath_post_title => '//post-title/text()',
    #   :xpath_post_content => '//post-body/text()',
    #   :xpath_post_date => '//post-date/text()',
    #   :xpath_post_url => '//post-id/text()',
    #   :xpath_blog_title => '//blog-title/text()',
    #   :xpath_blog_url => '//blog-url/text()')
  end

  def self.down
    drop_table :feedsucker_feeds
    drop_table :feedsucker_posts
  end
end
