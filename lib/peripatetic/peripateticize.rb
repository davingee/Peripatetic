# require "peripatetic/version"
# require 'peripatetic/location'
# require 'peripatetic/city'
# require 'peripatetic/country'
# require 'peripatetic/postal_code'
# require 'peripatetic/region'
# 
# module Peripatetic
#   
#   module ClassMethods
#     def peripateticize
#     end
#     # def acts_as_peripatetic
#     #   send :include, Peripatetic
#     # end
#   end
#   
#   module ModelMethods
#   
#   end
# 
#   module HelperMethods
#     def nested_form_builder
#     # <%= f.fields_for poly_locations(@user, 1) do |builder| %>
#     #   <% if builder.object.new_record? %>
#     #     <%= builder.hidden_field :ip, :value => ip_address %>
#     #   <div class="field">
#     #     <%= builder.label :street %><br />
#     #     <%= builder.text_field :street %>
#     #   </div>
#     #   <div class="field">
#     #     <%= builder.label :accessor_postal_code %><br />
#     #     <%= builder.text_field :accessor_postal_code, :value => get_accessor_postal_code(builder.object)[:postal_code] %>
#     #   </div>
#     #   <div class="field">
#     #     <%= builder.label :accessor_country %><br />
#     #     <%= builder.country_select :accessor_country, get_accessor_postal_code(builder.object)[:country] %>
#     #   </div>
#     #   <% end %>
#     # <% end %>
#     end
# 
#     def ip_address
#       (Rails.env.development? or Rails.env.test?) ? '206.127.79.163' : (env['HTTP_X_REAL_IP'] ||= env['REMOTE_ADDR'])
#     end
# 
#     def get_country
#       # Geokit::Geocoders::google = "AIzaSyAi43R79isU8MeS7ISBxAdUUe2phnoxpoM"
#       # res = GeoKit::Geocoders::IpGeocoder.geocode(ip_address)
#       # if res.success
#       #   res.country
#       #   res.country_code
#       #   # get_country = {:country => res.country, :country_code => res.country_code}
#       # end
#       res = Geocoder.search(ip_address)
#       if res.first
#         @get_country = { :ip => ip_address, :country => res.first.country, :postal_code => res.first.postal_code }
#       end
#     end
# 
#     def get_accessor_postal_code(model)
#       if model.postal_code.blank?
#         res = Geocoder.search(ip_address)
#         if res.first
#           @get_accessor_postal_code = { :ip => ip_address, :country => res.first.country, :postal_code => res.first.postal_code }
#         end
#       else
#         @get_accessor_postal_code = { :ip => ip_address, :country => model.postal_code.country_name, :postal_code => model.postal_code.name }
#       end
#     end
# 
#     def poly_locations(model, amount=false)
#       if amount == false
#         model.build_location 
#       else
#         amount.times { model.locations.build }
#       end
#       :locations
#     end
#   end
# end
# ActionView::Base.send :include, Peripatetic::HelperMethods
# 
# module Peripatetic::ActiveRecord
# end