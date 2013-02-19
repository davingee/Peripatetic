module Peripatetic

  class PostalCode < ActiveRecord::Base
    attr_accessible :name, :city, :country_code, :region, :region_code, :latitude, :longitude
    # has_many :locations
  end

end
