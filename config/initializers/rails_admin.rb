require File.join(Rails.root, "lib", "rails_admin", "without_ports")

RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end

  # Current_admin_user is the same method like standart current_user in devise.
  # It's a hook for using devise in frontend (like Angular)
  config.current_user_method(&:current_admin_user)

  ## == Cancan ==
  config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  # config.excluded_models << "User"
  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export do
      only ['Node', 'Zte', 'Dlink', 'Cisco', 'Port', 'Customer']
    end
    bulk_delete
    show do
      only ['Node', 'Zte', 'Dlink', 'Cisco', 'Port', 'Customer', 'Location', 'Port', 'Comment']
    end
    edit
    delete
    without_ports do
      only ['Node', 'Zte', 'Dlink', 'Cisco']
    end
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model 'User' do
    list do
      field :email
      field :last_sign_in_at
      field :last_sign_in_ip
    end

    export do
      field :id
      field :email
      field :sign_in_count
      field :last_sign_in_at
      field :last_sign_in_ip
      field :created_at
      field :updated_at
    end

    edit do
      field :email
    end

  end

  %w(Node Cisco Zte Dlink).each do |imodel|
    config.model "#{imodel}" do
      list do
        exclude_fields :created_at, :updated_at, :id
      end
    end
  end


  config.model 'Port' do

    list do
      items_per_page 36

      configure :id do
        sort_reverse false   # will sort id increasing ('asc') first ones first (default is last ones first)
      end

      configure :node_id, :enum do
        help 'Please select Node'
        enum do
          Node.order(:name).collect {|p| [p.name, p.id]}
        end
      end
      filters [:node_id]

      exclude_fields :created_at, :id
      
    end

    edit do
      [:name, :state, :description, :node].each do |field|
        configure field do
          read_only true
        end
      end
    end
    
  end
end
