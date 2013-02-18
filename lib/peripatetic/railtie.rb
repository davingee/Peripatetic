
module Peripatetic
  require 'rails'
  class Railtie < Rails::Railtie
    initializer 'peripatetic.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        ::ActiveRecord::Base.send :include, Peripatetic::Peripateticize
      end
    end
  end
end

