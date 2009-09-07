namespace :feedsucker do
  desc "Suck (fetch & load) every FeedsuckerFeed source stored at DB"
  task :suck_all => :environment do
    FeedsuckerFeed.suck_all! 
  end
end
