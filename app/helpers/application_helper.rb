module ApplicationHelper
  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} alert-dismissible", role: 'alert') do
        concat(content_tag(:button, class: 'close', data: { dismiss: 'alert' }) do
          concat content_tag(:span, '&times;'.html_safe, 'aria-hidden' => true)
          concat content_tag(:span, 'Close', class: 'sr-only')
        end)
        concat message
      end)
    end
    nil
  end
  
  def update_ports_info(node_ids)
    node_total_quantity   = node_ids.count
    node_quantity         = 0
    port_total_quantity   = 0
    port_updated_quantity = 0
    port_created_quantity = 0
    port_passed_quantity  = 0

    node_ids.each do |id|
      begin
        node = Node.find(id)
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
    result = {
      node_total_quantity: node_total_quantity,
      node_quantity: node_quantity,
      port_total_quantity: port_total_quantity,
      port_updated_quantity: port_updated_quantity,
      port_created_quantity: port_created_quantity,
      port_passed_quantity: port_passed_quantity
    }
    result
  end

  def notification_text(result, seconds, user = nil)
    "Оброблено комутаторів #{result[:node_quantity]} з #{result[:node_total_quantity]},\nВсього портів #{result[:port_total_quantity]}:\n    оновлено - #{result[:port_updated_quantity]},\n    створено - #{result[:port_created_quantity]}.\nВитрачено часу #{seconds.to_i/60} хв. #{seconds.to_i%60} сек." + (user ? "\nЗапит виконав користувач: " + user : "")
  end

end
