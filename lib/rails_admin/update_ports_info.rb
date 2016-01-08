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

            start_time = Time.now
            node_total_quantity   = @objects.count
            node_quantity         = 0
            port_total_quantity   = 0
            port_updated_quantity = 0
            port_created_quantity = 0
            port_passed_quantity  = 0

            @objects.each do |node|
              begin
                ports = node.ports
                port_total_quantity += ports.count
                gotten_ports = node.get_ports
                next if gotten_ports.empty?
                gotten_ports.zip(ports).each do |pair|
                  # pair[0] - ports's attributes reseived from node
                  # pair[1] - existing port's attributes
                  if pair[1] # if port exist do
                    pair[1].assign_attributes(pair[0])
                    if pair[1].changed? && pair[1].save
                      port_updated_quantity += 1
                    else
                      port_passed_quantity += 1
                    end
                  else # if port does not exist create new port
                    port = Port.new(pair[0].merge({node_id: node.id}))
                    port.save
                    port_created_quantity += 1
                    port_total_quantity += 1
                  end
                end
                node_quantity += 1
              rescue
                next
              end
            end

            begin
              `notify-send "Оновлення інформації про порти" "Оброблено #{node_quantity} комутаторів з #{node_total_quantity},\nпортів:\n    оновлено - #{port_updated_quantity}\n    пропущено - #{port_passed_quantity}\n    створено - #{port_created_quantity}.\nВсього портів: #{port_total_quantity + port_created_quantity}.\nВитрачено часу #{(Time.now.to_i - start_time.to_i)/60} хв. #{(Time.now.to_i - start_time.to_i)%60} сек." -i gtk-info`
            rescue
              puts "Обновление информации о портах\nВідпрацьовано #{node_quantity} комутаторів з #{node_total_quantity},\nпортів:\n    оновлено - #{port_updated_quantity}\n    пропущено - #{port_passed_quantity}\n    створено - #{port_created_quantity}.\nВсього портів: #{port_total_quantity + port_created_quantity}.\nВитрачено часу #{(Time.now.to_i - start_time.to_i)/60} хв. #{(Time.now.to_i - start_time.to_i)%60} сек."
            ensure
              flash[:notice] = "
                Оброблено #{node_quantity} комутаторів з #{node_total_quantity}.
                Портів:
                  оновлено - #{port_updated_quantity},
                  пропущено - #{port_passed_quantity},
                  cтворено - #{port_created_quantity}.
                Всього портів: #{port_total_quantity + port_created_quantity}.

                Витрачено часу #{(Time.now.to_i - start_time.to_i)/60} хв. #{(Time.now.to_i - start_time.to_i)%60} сек."
              redirect_to back_or_index
            end

          end
        end
      end
    end
  end
end