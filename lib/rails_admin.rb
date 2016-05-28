module RailsAdmin
  module Config
    module Actions
      class Dashboard < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :root? do
          true
        end

        register_instance_option :breadcrumb_parent do
          nil
        end

        register_instance_option :controller do
          proc do
            #You can specify instance variables

          # Time series chart
            @data = Port.updated_per_day.drop(7)

          # Pie chart
            nodes = Node.group(:type).count
            @pie_data = []
            nodes.each do |node, quantity|
              @pie_data <<  "{
                              name: '#{node}',
                              y: #{quantity},
                              drilldown: '#{node.downcase}'
                            }"
            end
            @pie_data = @pie_data.join(",\n").html_safe

            @pie_drilldown = []
            nodes.each do |node, quantity|
              data = node.constantize.group(:model).count.to_a
              @pie_drilldown << "{
                                  id: '#{node.downcase}',
                                  name: '#{node}',
                                  data: #{data}
                                }"
            end
            @pie_drilldown = @pie_drilldown.join(",\n").html_safe

          # Bar chart
            # bar_chart = Node.joins(:ports).group(:type, :state).count
            admin_down = Node.joins(:ports).where("ports.state = ?", "admin down").group(:type).count
            down = Node.joins(:ports).where("ports.state = ?", "down").group(:type).count
            up = Node.joins(:ports).where("ports.state = ?", "up").group(:type).count

            @admin_down=[]
            @down=[]
            @up=[]
            nodes.each do |node, quantity|
              @admin_down << admin_down[node].to_i
              @down << down[node].to_i
              @up << up[node].to_i
            end



            #You can access submitted params (just submit your form to the dashboard).
            if params[:xyz]
              @do_something = "here"
            end

            #You can specify flash messages
            # flash.now[:danger] = "Some type of danger message here."

            #After you're done processing everything, render the new dashboard
            render @action.template_name, status: 200
          end
        end

        register_instance_option :route_fragment do
          ''
        end

        register_instance_option :link_icon do
          'icon-home'
        end

        register_instance_option :statistics? do
          false
        end
      end
    end
  end
end