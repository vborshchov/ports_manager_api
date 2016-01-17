require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminUpdatePortsInfo
end

module RailsAdmin
  module Config
    module Actions

      class UpdatePortsInfo < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :bulkable? do
          true
        end
 
        register_instance_option :controller do
          Proc.new do
            # Get all selected rows
            @objects = list_entries(@model_config, :destroy)
            node_ids = @objects.pluck(:id)
            PortsWorker.perform_async(node_ids)
            flash[:notice] = "Процесс оновлення портів успішно запущено, ви можете далі користуватися сервісом"
            redirect_to back_or_index
          end
        end
      end
    end
  end
end