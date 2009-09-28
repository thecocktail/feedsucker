class FeedsuckerPost < ActiveRecord::Base
  belongs_to :feed, :class_name => 'FeedsuckerFeed', :foreign_key => 'feedsucker_feed_id'
  validates_presence_of :feed

  def method_missing(method, *args, &block)
   if (method.to_s =~ /^(.+)_without_tags$/)
     if str = self.send($1)
       str.gsub!(/&lt;.*?&gt;/,'')
       begin
         ActionController::Base.helpers.strip_tags(str)
       rescue
         include ActionView::Helpers::TextHelper
         strip_tags(str)
       end
     end
   else
     super
   end
 end

end
