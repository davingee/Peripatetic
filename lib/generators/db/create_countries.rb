class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name
      t.string :continent
      t.string :alpha2
      t.string :alpha3
      t.string :country_code
      t.string :currency
      t.string :international_prefix
      t.string :ioc
      t.float :latitude
      t.float :longitude
      t.string :names
      t.string :national_destination_code_lengths
      t.string :national_number_lengths
      t.string :national_prefix
      t.string :number
      t.string :region
      t.string :subregion
      t.string :un_locode
      t.string :languages
      t.string :nationality
      t.string :address_format
      t.string :alt_currency
      t.integer :position
      t.timestamps
    end
    add_index :countries, :name, :position
  end
end
