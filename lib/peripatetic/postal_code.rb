module Peripatetic

  class PostalCode < ActiveRecord::Base
    attr_accessible :name, :city_id, :region_id, :country_id
    has_many :locations
    belongs_to :city
    belongs_to :region
    belongs_to :country
  end

end
