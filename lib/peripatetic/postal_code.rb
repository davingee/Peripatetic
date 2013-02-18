module Peripatetic

  class PostalCode < ActiveRecord::Base
    attr_accessible :name, :city_id, :region_id, :country_id
    has_many :locations#,  :class_name => "::Peripatetic::Location"
    belongs_to :city#,     :class_name => "::Peripatetic::City"
    belongs_to :region#,   :class_name => "::Peripatetic::Region"
    belongs_to :country#,  :class_name => "::Peripatetic::Country"
  end

end
