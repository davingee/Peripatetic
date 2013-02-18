require "peripatetic/version"
require 'peripatetic/location'
require 'peripatetic/city'
require 'peripatetic/country'
require 'peripatetic/postal_code'
require 'peripatetic/region'

module Peripatetic
  def self.included(base)
    # base.extend(ClassMethods).relate
    base.extend ClassMethods

    base.class_eval do
      attr_accessible :locations_attributes
      has_many :locations, :as => :locationable, :class_name => "Peripatetic::Location"
      accepts_nested_attributes_for :locations, :reject_if => lambda { |a| a[:accessor_postal_code].blank? }, :allow_destroy => true
      # has_one :location, :as => :locationable
      # accepts_nested_attributes_for :location, :reject_if => lambda { |a| a[:accessor_postal_code].blank? }, :allow_destroy => true
    end
    
  end
  
  module ClassMethods
  end
  
  module ModelMethods
  
  end

  module HelperMethods

    def ip_address
      (Rails.env.development? or Rails.env.test?) ? '206.127.79.163' : (env['HTTP_X_REAL_IP'] ||= env['REMOTE_ADDR'])
    end

    def get_country
      # Geokit::Geocoders::google = "AIzaSyAi43R79isU8MeS7ISBxAdUUe2phnoxpoM"
      # res = GeoKit::Geocoders::IpGeocoder.geocode(ip_address)
      # if res.success
      #   res.country
      #   res.country_code
      #   # get_country = {:country => res.country, :country_code => res.country_code}
      # end
      res = Geocoder.search(ip_address)
      if res.first
        @get_country = { :ip => ip_address, :country => res.first.country, :postal_code => res.first.postal_code }
      end
    end

    def get_accessor_postal_code(model)
      if model.postal_code.blank?
        res = Geocoder.search(ip_address)
        if res.first
          @get_accessor_postal_code = { :ip => ip_address, :country => res.first.country, :postal_code => res.first.postal_code }
        end
      else
        @get_accessor_postal_code = { :ip => ip_address, :country => model.postal_code.country_name, :postal_code => model.postal_code.name }
      end
    end

    def poly_locations(model, amount=false)
      if amount == false
        model.build_location 
      else
        amount.times { model.locations.build }
      end
      :locations
    end
  end

end

ActionView::Base.send :include, Peripatetic::HelperMethods
# class ActiveRecord::Base
#   include Peripatetic
# end
