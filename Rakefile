#  ____       _         __ _ _
# |  _ \ __ _| | _____ / _(_) | ___
# | |_) / _` | |/ / _ \ |_| | |/ _ \
# |  _ < (_| |   <  __/  _| | |  __/
# |_| \_\__,_|_|\_\___|_| |_|_|\___|
#
require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require './app'
  end

  # desc 'Migrate the database'
  # task migrate: :environment do
  #   ActiveRecord::Migrator.migrate('db/migrate')
  # end

  desc 'Rollback the database'
  task rollback: :environment do
    ActiveRecord::Migrator.rollback('db/migrate')
  end
end
