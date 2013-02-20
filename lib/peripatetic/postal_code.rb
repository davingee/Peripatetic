module Peripatetic

  class PostalCode < ActiveRecord::Base
    attr_accessible :postal_code, :city, :country_code, :region, :region_code, :latitude, :longitude, :time_zone, :country_id
    belongs_to :country
    # has_many :locations
  end

end
