class FeedsuckerGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'create_feedsucker_tables.rb', 'db/migrate'
    end
  end

  def file_name
    'create_feedsucker_tables'
  end
  
  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} feedsucker "
    end
end
