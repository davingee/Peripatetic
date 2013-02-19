class CreatePostalCode < ActiveRecord::Migration
  def change
    create_table :postal_codes do |t|
      t.string :name
      t.string :city
      t.string :region
      t.string :region_code
      t.string :country_code
      t.float :latitude
      t.float :longitude
      t.boolean :geocoded
      t.string :time_zone
      t.integer :country_id
      t.timestamps
    end
    add_index :postal_codes, :country_code
    add_index :postal_codes, :name
  end
end
