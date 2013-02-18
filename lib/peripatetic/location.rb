require 'geocoder'
module Peripatetic

  class Location < ActiveRecord::Base
    attr_accessible :latitude, :longitude, :street, :accessor_country, :accessor_postal_code, :time_zone, :ip
    attr_accessor :accessor_country, :accessor_postal_code, :time_zone, :ip

    belongs_to :locationable, :polymorphic => true

    belongs_to :country
    belongs_to :region
    belongs_to :postal_code
    belongs_to :city

    reverse_geocoded_by :latitude, :longitude
    geocoded_by :location_attributes_available do |obj, results|
      puts "Geocoding Yo!"
      if geo = results.first
        obj.latitude = geo.latitude if geo.latitude
        obj.longitude = geo.longitude if geo.longitude
        if geo.state.present? and geo.state_code.present?
          the_region = Region.find_or_create_by_name_and_code(geo.state.downcase, geo.state_code.downcase) 
          obj.region_id = the_region.id
        end
        obj.city_id = the_region.cities.find_or_create_by_name(geo.city.downcase).id if geo.city.present?
        if geo.postal_code.present? and geo.country_code.present?
          the_postal_code = PostalCode.find_or_create_by_name_and_country_code(geo.postal_code.upcase, geo.country_code.upcase)
          obj.postal_code_id = the_postal_code.id
          # the_postal_code.time_zone =  obj.get_time_zone
        end
      end
    end
    after_validation :geocode#, :if => :street_or_postal_code_changed?

    # validate :validate_postal_code
    def validate_postal_code
      return unless postal_code_changed?
      return if postal_code.blank?
      if GoingPostal.postcode?(postal_code, country_code)
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
      postal_code.present?
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

    def street_or_postal_code_changed?
      true
      # return true if street_changed?
      # if postal_code?
      #   return true if postal_code.name != accessor_postal_code
      # else
      #   return true if accessor_postal_code?
      # end
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
      "#{street} #{city} #{region} #{postal_code}"
    end

    def city_name
      city.name.split(" ").each{|word| word.capitalize!}.join(" ") if city?
    end

    def postal_code_name
      postal_code.name if postal_code?
    end

    def region_name
      region.name.split(" ").each{|word| word.capitalize!}.join(" ") if region?
    end

    def country_name
      postal_code.country_code if postal_code?
    end

  end
end
