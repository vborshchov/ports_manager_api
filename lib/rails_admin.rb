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
            @data = Port.updated_per_day.drop(7)

            @nodes = Node.group(:type).count.values

            admin_down = Node.joins(:ports).where("ports.state = ?", "admin down").group(:type).count
            down = Node.joins(:ports).where("ports.state = ?", "down").group(:type).count
            up = Node.joins(:ports).where("ports.state = ?", "up").group(:type).count

            @admin_down=[]
            @down=[]
            @up=[]
            ['Cisco', 'Dlink', 'Huawei', 'Iskratel', 'Zte'].each do |node|
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
          true
        end
      end
    end
  end
end