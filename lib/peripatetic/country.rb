module Peripatetic

  class Country < ActiveRecord::Base
    attr_accessible :name
    has_many :postal_codes
  end

end