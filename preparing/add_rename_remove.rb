class AddRenameRemove < ActiveRecord::Migration
  def up
    add_column    :postal_codes,  :id,          :primary_key
    add_column    :postal_codes,  :geocoded,    :boolean,     :default => false
    add_column    :postal_codes,  :time_zone,   :string,      :default => nil
    add_column    :postal_codes,  :country_id,  :integer
    rename_column :postal_codes,  :countrycode, :country_code
    rename_column :postal_codes,  :postalcode,  :postal_code
    rename_column :postal_codes,  :placename,   :city
    rename_column :postal_codes,  :admin1name,  :region
    rename_column :postal_codes,  :admin1code,  :region_code
    remove_column :postal_codes,  :admin2name,  :admin2code,  :admin3name, :admin3code, :accuracy
    add_index     :postal_codes,  :postal_code
    add_index     :postal_codes,  :country_code
    # add_index     :postal_codes,  :id
  end

  def down
  end
end
