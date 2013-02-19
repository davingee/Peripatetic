class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :street
      t.string :city
      t.string :region
      t.string :region_code
      t.string :postal_code
      t.string :country
      t.string :country_code
      t.float :latitude
      t.float :longitude
      t.string :locationable_type
      t.integer :locationable_id
      t.boolean :geocoded
      t.integer :country_id
      t.timestamps
    end
  end
end
