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

        register_instance_option :member do
          true
        end

        register_instance_option :link_icon do
          'icon-retweet'
        end
 
        register_instance_option :controller do
          Proc.new do
            # Get all selected rows
            @objects = list_entries(@model_config, :destroy)
            user =  current_admin_user.try(:name) || current_admin_user.email
            node_ids =  if @object.try(:id).nil?
                          @objects.pluck(:id)
                        else
                          [@object.id]
                        end
            PortsWorker.perform_async(node_ids, user)
            flash[:notice] = "Процесс оновлення портів успішно запущено, ви можете далі користуватися сервісом"
            redirect_to back_or_index
          end
        end
      end
    end
  end
end