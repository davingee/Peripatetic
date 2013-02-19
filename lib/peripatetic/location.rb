require 'geocoder'
module Peripatetic

  class Location < ActiveRecord::Base
    attr_accessible :latitude, :longitude, :street, :accessor_country, :accessor_postal_code, :time_zone, :ip
    attr_accessor :accessor_country, :accessor_postal_code, :time_zone, :ip

    belongs_to :locationable, :polymorphic => true
    belongs_to :country
    # belongs_to :postal_code
    
    Geocoder.configure(:timeout => 1) 
    reverse_geocoded_by :latitude, :longitude
    geocoded_by :location_attributes_available do |obj, results|
      puts "Geocoding Yo!"
      if geo = results.first
        obj.latitude = geo.latitude if geo.latitude
        obj.longitude = geo.longitude if geo.longitude
        if geo.state.present? and geo.state_code.present?
          obj.region = geo.state
        end
        obj.city = geo.city.downcase if geo.city.present?
        obj.geocoded = true
      end
    end
    # after_validation :geocode, :if => :street_or_postal_code_changed?
    
    after_validation :geocode,              :if     => :street_present_or_changed?
    after_validation :inject_location_info
    
    validate :validate_postal_code
    def validate_postal_code
      # return unless postal_code_changed? and postal_code.present?
      if PostalCode.find_by_name_and_country_code(accessor_postal_code ,accessor_country).present?
        true
      else
        errors.add(:postal_code, "appears to be invalid") 
        false
      end
    end

    def street?
      street.present?
    end

    def city?
      city.present?
    end

    def postal_code?
      postal.present?
    end

    def accessor_postal_code?
      accessor_postal_code.present?
    end

    def region?
      region.present?
    end

    def accessor_country?
      accessor_country.present?
    end

    def inject_location_info
      p_c = PostalCode.find_by_name_and_country_code(accessor_postal_code, accessor_country)
      puts "almost injecting"
      return unless postal_code_changed? or self.new_record?
      puts "injecting"
      self.postal_code = p_c.name
      self.city = p_c.city
      self.region = p_c.region
      self.country_code = p_c.country_code
      self.latitude = p_c.latitude
      self.longitude = p_c.longitude
    end
    
    def street_present_or_changed?
      return true if street_changed? and street.present?
    end

    def fill_in_city_region_postal_code
    end
    
    def location_attributes_available
      if street? and accessor_postal_code?
        "#{street} #{accessor_postal_code} #{accessor_country}"
      elsif accessor_postal_code?
        "#{accessor_postal_code} #{accessor_country}"
      elsif accessor_country?
        accessor_country
      else
        ip
      end
    end

    def get_time_zone
      # latitude = l.latitude
      # longitude = l.longitude
      url = "http://api.geonames.org/timezone?lat=#{latitude}&lng=#{longitude}&username=davinjay"
      doc = Nokogiri::HTML(open(url))
      doc.search("timezoneid").first.children.first.to_s
      # self.postal_code.time_zone = self.time_zone
      # self.postal_code.save
    end

    def city_address
      "#{city} #{region}"
    end

    def full_address
      ("#{street} #{city} #{region} #{postal}").chomp
    end

  end
end
