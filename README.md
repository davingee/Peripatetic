Peripatetic

Drop in Location has_one or has_many

Installation:

Add this line to your application's Gemfile:

    gem 'peripatetic'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install peripatetic

Usage:

Add include Peripatetic to the model you want locations
then just drop in nested form into the form

<%= f.fields_for poly_locations(model, number_of_times_to_build) do |builder| %>
  <% if builder.object.new_record? %>
    <%= builder.hidden_field :ip, :value => ip_address %>
  <div class="field">
    <%= builder.label :street %><br />
    <%= builder.text_field :street %>
  </div>
  <div class="field">
    <%= builder.label :accessor_postal_code, "Postal Code" %><br />
    <%= builder.text_field :accessor_postal_code, :value => get_accessor_postal_code(builder.object)[:postal_code] %>
  </div>
  <div class="field">
    <%= builder.label :accessor_country, "Country" %><br />
    <%= builder.country_select :accessor_country, get_accessor_postal_code(builder.object)[:country] %>
  </div>
  <% end %>
<% end %>


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
