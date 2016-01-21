require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

namespace :nodes do
  desc "Update information about all ports of all nodes
    or nodes of certain type in the database"
  task :update_ports, [:node_ids, :model_name] => :environment do |t, args|
    start_time = Time.now
    args.with_defaults(:node_ids => '', :model_name => "Node")
    node_ids_array = args[:node_ids].split(' ').map{ |s| s.to_i }

    model = args[:model_name].capitalize

    if node_ids_array.empty?
      array = model.constantize.pluck(:id)
    else
      array = model.constantize.pluck(:id) & node_ids_array
    end

    result = update_ports_info(array)

    begin
      `notify-send "Оновлення інформації про порти" "#{notification_text(result, Time.now.to_i - start_time.to_i)}" -i gtk-info`
    ensure
      puts "-----------------------------------------------------\n#{Time.now}\n#{notification_text(result, Time.now.to_i - start_time.to_i)}"
    end
  end
end