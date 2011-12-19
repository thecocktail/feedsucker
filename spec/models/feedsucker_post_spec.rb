require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module FeedsuckerPostMacros
  def self.included(receiver)
    receiver.extend         ExampleGroupMethods
  end

  module ExampleGroupMethods
    def before_do
      before do
       @feed_post = FeedsuckerPost.new
      end
    end

    def it_should_strip_standard_tags(field)
      it 'should strip "standard" tags' do
        @feed_post.send "#{field}=", "<p>Tengo el coraz&#243;n contento, lleno de alegr&#237;a.</p>"
        @feed_post.send("#{field}_without_tags").should == 'Tengo el coraz&#243;n contento, lleno de alegr&#237;a.'
      end
    end
    def it_should_strip_tags_with_XML_entities(field)
      it 'should strip tags with XML entities' do
        @feed_post.send "#{field}=", "&lt;p&gt;Tengo el coraz&#243;n contento, lleno de alegr&#237;a.&lt;/p&gt;"
        @feed_post.send("#{field}_without_tags").should == 'Tengo el coraz&#243;n contento, lleno de alegr&#237;a.'
      end
    end
    def it_should_strip_any_kind_of_tag(field)
      it 'should strip any kind of tag' do
        @feed_post.send "#{field}=", "&lt;p&gt;Tengo <p>el</p> coraz&#243;n contento, lleno de alegr&#237;a.&lt;/p&gt;"
        @feed_post.send("#{field}_without_tags").should == 'Tengo el coraz&#243;n contento, lleno de alegr&#237;a.'
      end
    end
  end
end

describe FeedsuckerPost, 'attributes_without_tags' do
  include FeedsuckerPostMacros
  before_do
  %w{title content}.each do |method|
    it_should_strip_standard_tags method
    it_should_strip_tags_with_XML_entities method
    it_should_strip_any_kind_of_tag method
  end
end
