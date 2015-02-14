class Site < ActiveRecord::Base
  validates :url, :total_lines, :internal, :external, presence: true
  validates_uniqueness_of :url
end
