require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminReservedPorts
end

module RailsAdmin
  module Config
    module Actions

      class ReservedPorts < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :controller do
          Proc.new do
            @objects = params[:model_name].capitalize.constantize.reserved
            render "index"
          end
        end

        register_instance_option :collection do
          true
        end

        register_instance_option :link_icon do
          'icon-warning-sign'
        end
      end
    end
  end
end