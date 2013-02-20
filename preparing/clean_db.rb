require "iconv"
class CleanDb
  
  def grab_region_names
    yaml_files = Dir.entries("#{Rails.root}/data/subdivisions").sort
    yaml_files.each do |file|
      regions = YAML::load( File.open( "#{Rails.root}/data/subdivisions/#{file}" ) )
      regions.each do |region|
        country_code = region.first
        Peripatetic::PostalCode.find_by_country_code(country_code)
      end
    end
  end
  
  def geocode_postal_code
    Peripatetic::PostalCode.find_all_by_place_name("Soğuksu")
    # ic = Iconv.new('US-ASCII//IGNORE', 'UTF-8')
    Geokit::Geocoders::google = "AIzaSyAi43R79isU8MeS7ISBxAdUUe2phnoxpoM"
    Geokit::Geocoders::google = "ABQIAAAAjkocf-uapJh4zp82saxrjRTJQa0g3IQ9GZqIMmInSLzwtGDKaBTVoUPc9vOiQIy1jPApkJIrsM5V6g"
    Peripatetic::PostalCode.where(:country_code => "US", :geocoded => false).find_in_batches do |group|
      group.each do |postal_code|
        sleep 0.5
        geocode = "#{postal_code.postal_code} #{postal_code.country_code}"        
        # res = Geokit::Geocoders::GoogleGeocoder.geocode(ic.iconv(geocode))
        res = Geokit::Geocoders::GoogleGeocoder.geocode(geocode)
        if res.success
          if postal_code.city.blank? and  res.city.present?
            postal_code.city = res.city.downcase
          end
          postal_code.region_code = res.state if res.state.present?
          postal_code.latitude = res.lat if res.lat.present?
          postal_code.longitude = res.lng if res.lng.present?
          postal_code.geocoded = true
          postal_code.save
          puts "address is #{postal_code.city} #{postal_code.region_code}, #{postal_code.postal_code} #{postal_code.country_code}"
          puts "------------------------------------------------------"
        else
          puts "Place Name = #{postal_code.place_name} Region Code =  #{postal_code.region_code} Postal Code = #{postal_code.name} Country Code = #{postal_code.country_code}"
          puts "Unsuccessful"
          puts "***********************************************"
        end
      end
    end
  end


  def reverse_geo_code
    Geokit::Geocoders::google = "ABQIAAAAjkocf-uapJh4zp82saxrjRTJQa0g3IQ9GZqIMmInSLzwtGDKaBTVoUPc9vOiQIy1jPApkJIrsM5V6g"
    Peripatetic::PostalCode.where(:country_code => "US", :geocoded => true).find_in_batches do |group|
      group.each do |p|
        res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode([p.latitude, p.longitude])
        # res = Geokit::Geocoders::GoogleGeocoder.reverse_geocode([54.0559566,-0.7662772])
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
  
  # def time_zone
  #   # Peripatetic::PostalCode.where(:time_zone => "America/Chicago")
  #   Peripatetic::PostalCode.where(:country_code => "US", :time_zone => "f").find_in_batches do |group|
  #     group.each do |p|
  #       next if p.latitude.blank? or p.longitude.blank?
  #       url = "http://api.geonames.org/timezone?lat=#{p.latitude}&lng=#{p.longitude}&username=david"
  #       doc = Nokogiri::HTML(open(url))
  #       time_zone = doc.search("timezoneid").first.children.first.to_s if doc.search("timezoneid").first.present?
  #       p.time_zone = time_zone if time_zone.present?
  #       puts "The Time zone for p.postal_code is #{time_zone}"
  #       p.save
  #     end
  #   end
  # end

  # Peripatetic::PostalCode.select(:country_code).uniq
  # Peripatetic::Country.select(:name).uniq
  def get_time_zone
    p = Peripatetic::PostalCode.where(:country_code => "US", :postal_code => "40356")
    
    # Peripatetic::PostalCode.where(:time_zone => "America/Chicago")
    # Peripatetic::PostalCode.where(:country_code => "US", :time_zone => "f", :geocoded => true).find_in_batches
    Peripatetic::PostalCode.where(:country_code => "US", :time_zone => "f", :geocoded => true).find_in_batches do |group|
      group.each do |p|
        next if p.latitude.blank? or p.longitude.blank?
        time_zones_near = Geoname.near([p.latitude, p.longitude], 1)
        next if time_zones_near.blank?
        p.update_attributes(:time_zone => time_zones_near.first.timezone) if time_zones_near.map(&:timezone).uniq.count == 1
      end
    end
  end
  
  Peripatetic::PostalCode.where(:country_id => nil).count
  def associate_countries
    Peripatetic::PostalCode.where(:country_id => nil).find_in_batches do |group|
      group.each do |p|
        country = Peripatetic::Country.where(:alpha2 => p.country_code)
        if country.count > 1
          puts "Found this many #{country.count}"
          next
        end
        p.update_attributes(:country_id => country.first.id)
      end
    end
  end
  
  def remove_time_zone
    Peripatetic::PostalCode.find_in_batches do |group|
      group.each do |p|
        next if p.time_zone == "f"
        p.time_zone = "f"
        p.save
      end
    end
  end
  
  def change_id
    ActiveRecord::Base.connection.execute("TRUNCATE countries")
    ActiveRecord::Base.connection.reset_pk_sequence!('countries')
    ActiveRecord::Base.connection.execute('ALTER TABLE countries AUTO_INCREMENT = 1')
    Peripatetic::Country.all
## Postal Code
    i = 0
    Peripatetic::PostalCode.find_in_batches do |group|
      group.each do |postal_code|
        i =  i + 1
        puts i
      end
    end
## Countries

    i = 0
    Peripatetic::Country.all.each do |country|
      i =  i + 1
      puts i
      sql = "update records set id=#{i} where id=#{country.id}"
      ActiveRecord::Base.connection.execute(sql)
    end

    i = 0
    Peripatetic::Country.all.each do |country|
      i =  i + 1
      puts i
      country.id = i
      country.save
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
              puts "destroyed postal_code #{dup.postal_code}"
            end
          end
        else
          puts "Only one #{duplicates.first.postal_code} #{duplicates.count}"
        end
      end
    end
  end

  def query
    Peripatetic::Country
    Peripatetic::PostalCode.where(:postal_code => "8544")
    Peripatetic::PostalCode.where(:country_code => "AF", :region_code => "BDS")
  end

end