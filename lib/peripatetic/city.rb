module Peripatetic

  class City < ActiveRecord::Base
    attr_accessible :name, :region, :country
    has_many :locations
    has_many :postal_codes
    belongs_to :region
    belongs_to :country
  end

end
