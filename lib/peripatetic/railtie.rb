module Peripatetic
  require 'rails'
  class Railtie < Rails::Railtie
    initializer 'peripatetic.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        include, Peripatetic
      end
    end
  end
end