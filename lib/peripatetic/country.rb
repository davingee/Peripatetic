module Peripatetic

  class Country < ActiveRecord::Base
    attr_accessible :name, :code
    has_many :locations#,    :class_name => "::Peripatetic::Location"
    has_many :regions#,      :class_name => "::Peripatetic::Region"
    has_many :postal_codes#, :class_name => "::Peripatetic::PostalCode"
    has_many :cities#,       :class_name => "::Peripatetic::City"
  end

end
