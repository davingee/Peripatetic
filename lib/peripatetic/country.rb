module Peripatetic

  class Country < ActiveRecord::Base
    attr_accessible :name
    has_many :countries
  end

end