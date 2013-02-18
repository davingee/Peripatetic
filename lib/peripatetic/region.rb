module Peripatetic

  class Region < ActiveRecord::Base
    attr_accessible :name, :code, :country

    has_many :locations#,    :class_name => "::Peripatetic::Location"
    has_many :cities#,       :class_name => "::Peripatetic::City"
    has_many :postal_codes#, :class_name => "::Peripatetic::PostalCode"
    belongs_to :country#,    :class_name => "::Peripatetic::Country"
  end

end
