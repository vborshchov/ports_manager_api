require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminCustomerPorts
end

module RailsAdmin
  module Config
    module Actions

      class CustomerPorts < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :controller do
          Proc.new do
            redirect_to(
              controller: 'main',
              action: 'index',
              model_name: "port",
              utf8: "✓",
              "f[customer][1][o]": "like",
              "f[customer][1][v]": params[:id]
            )
          end
        end

        register_instance_option :member do
          true
        end

        register_instance_option :link_icon do
          'icon-list'
        end
      end

    end
  end
end