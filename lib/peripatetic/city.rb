module Peripatetic

  class City < ActiveRecord::Base
    attr_accessible :name, :region, :country
    has_many :locations#,    :class_name => "::Peripatetic::Location"
    has_many :postal_codes#, :class_name => "::Peripatetic::PostalCode"
    belongs_to :region#,     :class_name => "::Peripatetic::Region"
    belongs_to :country#,    :class_name => "::Peripatetic::Country"
  end

end
