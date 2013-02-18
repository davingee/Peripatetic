module Peripatetic

  class Country < ActiveRecord::Base
    attr_accessible :name, :code
    has_many :locations
    has_many :regions
    has_many :postal_codes
    has_many :cities
  end

end
