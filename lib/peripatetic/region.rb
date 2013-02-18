module Peripatetic

  class Region < ActiveRecord::Base
    attr_accessible :name, :code, :country

    has_many :locations
    has_many :cities
    has_many :postal_codes
    belongs_to :country
  end

end
