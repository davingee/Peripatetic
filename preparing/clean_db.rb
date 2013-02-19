require "iconv"
class CleanDb
  def geocode_postal_code
    Peripatetic::PostalCode.find_all_by_place_name("Soğuksu")

    ic = Iconv.new('US-ASCII//IGNORE', 'UTF-8')
    Geokit::Geocoders::google = "AIzaSyAi43R79isU8MeS7ISBxAdUUe2phnoxpoM"
    Peripatetic::PostalCode.where(:country_code => "US").find_in_batches do |group|
      group.each do |postal_code|
        sleep 0.1
        geocode = "#{postal_code.name} #{postal_code.country_code}"        
        res = Geokit::Geocoders::GoogleGeocoder.geocode(ic.iconv(geocode))
        if res.success
          if postal_code.city.blank? and  res.city.present?
            postal_code.city = res.city 
          end
          postal_code.region_code = res.state if res.state.present?
          postal_code.latitude = res.lat if res.lat.present?
          postal_code.longitude = res.lng if res.lng.present?
          postal_code.geocoded = true
          postal_code.save
          puts "address is #{postal_code.place_name} #{postal_code.region_code}, #{postal_code.name} #{postal_code.country_code}"
          puts "------------------------------------------------------"
        else
          
          # if geocode doesn't work reverse geocode
          res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode([postal_code.latitude, postal_code.longitude])
    
    
    
          Latitude: 54.0559566
          Longitude: -0.7662772
          res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode([54.0559566,-0.7662772])
          
          puts "Place Name = #{postal_code.place_name} Region Code =  #{postal_code.region_code} Postal Code = #{postal_code.name} Country Code = #{postal_code.country_code}"
          puts "Unsuccessful"
          puts "***********************************************"
        end
      end
    end
  end

  def update_america_postal_codes
    file_path = "#{Rails.root}/data/free-zipcode-database-Primary.csv"
    system "curl -O http://federalgovernmentzipcodes.us/free-zipcode-database-Primary.csv > #{file_path}"
    CSV.foreach("#{file_path}", headers: true) do |row|
      if row["Location"] =~ /NA-US-/
        postal_code = Peripatetic::PostalCode.find_or_initialize_by_postal_code_and_country_code(row["Zipcode"], "US")
        puts "postal code new record? #{postal_code.new_record?}"
        next unless postal_code.new_record?
        postal_code.city = row["City"]
        postal_code.region_code = row["State"]
        postal_code.longitude = row["Long"]
        postal_code.latitude = row["Lat"]
        postal_code.save
      end
      # Product.create! row.to_hash
    end
  end


  def find_duplicate_columns
    # Peripatetic::PostalCode.where(:postal_code => "YO17").map(&:region_code)
    Peripatetic::Country.select("COUNT(alpha2) as total, alpha2").
      group(:alpha2).
      having("COUNT(alpha2) > 1").
      order(:alpha2).
      map{|p| {p.alpha2 => p.total} }

    Peripatetic::PostalCode.select("COUNT(postal_code) as total, postal_code").
      group(:postal_code).
      having("COUNT(postal_code) > 1").
      order(:postal_code).
      map{|p| {p.postal_code => p.total} }
  end
  
  def lower_case_upper_case
    Peripatetic::PostalCode.find_in_batches do |group|
      group.each do |p|
        p.city = p.city.downcase if p.city
        p.region = p.region.downcase if p.region
        p.region_code = p.region_code.upcase if p.region_code
        p.save
      end
    end
  end
  
  def time_zone
    # Peripatetic::PostalCode.where(:time_zone => "America/Chicago")
    Peripatetic::PostalCode.where(:country_code => "US", :time_zone => "f").find_in_batches do |group|
      group.each do |p|
        next if p.latitude.blank? or p.longitude.blank?
        url = "http://api.geonames.org/timezone?lat=#{p.latitude}&lng=#{p.longitude}&username=david"
        doc = Nokogiri::HTML(open(url))
        time_zone = doc.search("timezoneid").first.children.first.to_s if doc.search("timezoneid").first.present?
        p.time_zone = time_zone if time_zone.present?
        puts "The Time zone for p.postal_code is #{time_zone}"
        p.save
      end
    end
  end
  
  def change_id
    ActiveRecord::Base.connection.execute("TRUNCATE countries")
    ActiveRecord::Base.connection.reset_pk_sequence!('countries')
    ActiveRecord::Base.connection.execute('ALTER TABLE countries AUTO_INCREMENT = 1')
    Peripatetic::Country.all
    
    Peripatetic::PostalCode.find_in_batches do |group|
      group.each do |postal_code|
        1 + 1
        postal_code.id = 
      end
    end
  end

  def rid_duplicats
    ActiveRecord::Base.logger = nil
    Peripatetic::PostalCode.find_in_batches do |group|
      group.each do |postal_code|
        duplicates = Peripatetic::PostalCode.find_all_by_country_code_and_postal_code(postal_code.country_code, postal_code.postal_code)
        if duplicates.count > 1
          duplicates.each do |dup|
            unless dup.id == postal_code.id
              dup.destroy
              puts "destroyed postal_code #{dup.name}"
            end
          end
        else
          puts "Only one #{duplicates.first.name} #{duplicates.count}"
        end
      end
    end
  end

  def query
    Peripatetic::Country
    Peripatetic::PostalCode.find_or_initialize_by_name_and_country("59601", "US")
  end

end