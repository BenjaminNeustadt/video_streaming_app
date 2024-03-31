class Asset < ActiveRecord::Base
  # has_a :title
  # has_a :description
  # has_a :playback_id
  # has_a :duration
  # has_many :tags

  def database_id
    self.id
  end

end

