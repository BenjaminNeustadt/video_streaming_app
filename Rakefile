# Rakefile
#
require 'sinatra/activerecord/rake'

namespace :db do
  desc "Migrate the database"
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  desc "Rollback the database"
  task :rollback => :environment do
    ActiveRecord::Migrator.rollback('db/migrate')
  end
end

