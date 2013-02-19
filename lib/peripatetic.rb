require "peripatetic/version"
require 'peripatetic/location'
require 'peripatetic/postal_code'
require 'peripatetic/country'

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
    # def acts_as_peripatetic
    #   send :include, Peripatetic
    # end
  end
  
  module ModelMethods
  
  end

  module HelperMethods
    def nested_form_builder
    # <%= f.fields_for poly_locations(@user, 1) do |builder| %>
    #   <% if builder.object.new_record? %>
    #     <%= builder.hidden_field :ip, :value => ip_address %>
    #   <div class="field">
    #     <%= builder.label :street %><br />
    #     <%= builder.text_field :street %>
    #   </div>
    #   <div class="field">
    #     <%= builder.label :accessor_postal_code, "Postal Code" %><br />
    #     <%= builder.text_field :accessor_postal_code, :value => get_accessor_postal_code(builder.object)[:postal_code] %>
    #   </div>
    #   <div class="field">
    #     <%= builder.label :accessor_country, "Country" %><br />
    #     <%= builder.country_select :accessor_country, get_accessor_postal_code(builder.object)[:country] %>
    #   </div>
    #   <% end %>
    # <% end %>
    end

    def all_countries
      Country.select([:id, :name, :position]).order("position ASC")
    end
    
    def ip_address
      (Rails.env.development? or Rails.env.test?) ? '206.127.79.163' : (env['HTTP_X_REAL_IP'] ||= env['REMOTE_ADDR'])
    end

    def get_country
      if builder.object.accessor_postal_code.present?
        @get_country = { :ip => ip_address, :country => builder.object.accessor_country, :postal_code => builder.object.accessor_postal_code }
      else
        res = Geocoder.search(ip_address)
        if res.first
          @get_country = { :ip => ip_address, :country => res.first.country, :postal_code => res.first.postal_code }
        end
      end
    end
    
    def get_accessors(model)
      @get_accessors ||= get_accessor_postal_code(model)
    end

    def get_accessor_postal_code(model)
      # return unless @get_accessor_postal_code.blank?
      if model.postal_code.blank?
        res = Geocoder.search(ip_address)
        if res.first
          country = Country.select([:id, :name, :position]).find_by_name(res.first.country)
          if country.present?
            country_id = country.id
          else
            country_id = Country.select([:id, :name, :position]).find_by_name("United States").id
          end
          model.country_id = country_id
          @get_accessor_postal_code = { :ip => ip_address, :postal_code => res.first.postal_code }
        else
          @get_accessor_postal_code = { :ip => ip_address, :postal_code => "" }
        end
      else
        @get_accessor_postal_code = { :ip => ip_address, :postal_code => model.postal_code }
      end
    end

    def peripatetic_locations(model, amount=false)
      if amount == false
        model.build_location 
      else
        amount.times { model.locations.build } if model.new_record?
      end
      :locations
    end
  end

end

ActionView::Base.send :include, Peripatetic::HelperMethods
# class ActiveRecord::Base
#   include Peripatetic
# end
