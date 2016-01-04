require File.join(Rails.root, "lib", "rails_admin", "without_ports")

def date_time_format_for(*options)
  options.each do |f|
    configure f do
      strftime_format "%H:%M:%S %d-%m-%Y"
    end
  end
end

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
  config.audit_with :paper_trail, 'Port', 'PaperTrail::Version' # PaperTrail >= 3.0.0

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
    history_index do
      only ['Port']
    end
    history_show do
      only ['Port']
    end
  end

  config.model 'User' do
    list do
      field :email
      date_time_format_for :created_at, :updated_at, :last_sign_in_at, :current_sign_in_at
      fields :last_sign_in_ip, :remember_created_at, :sign_in_count, :current_sign_in_at, :current_sign_in_ip, :created_at, :updated_at, :auth_token do
        visible do
          bindings[:view]._current_user.role == "admin"
        end
      end
    end

    export do
      field :id
      field :email
      field :sign_in_count
      field :last_sign_in_ip
      date_time_format_for :last_sign_in_at, :created_at, :updated_at
    end

    edit do
      field :email
      fields :password, :password_confirmation, :role do
        visible do
          bindings[:view]._current_user.role == "admin"
        end
      end
    end
  end

  config.model 'Customer' do
    create do
      exclude_fields :ports
    end

    edit do
      exclude_fields :ports
    end
  end
  
  %w(Node Cisco Zte Dlink Location Customer).each do |imodel|
    config.model "#{imodel}" do
      list do
        exclude_fields :created_at, :updated_at, :id
      end

      export do
        date_time_format_for :created_at, :updated_at
      end
    end
  end


  config.model 'Comment' do
    export do
      date_time_format_for :created_at, :updated_at
    end
  end

  config.model 'Port' do
    list do
      items_per_page 36
      configure :id do
        sort_reverse false   # will sort id increasing ('asc') first ones first (default is last ones first)
      end
      date_time_format_for :updated_at
      configure :node_id, :enum do
        help 'Please select Node'
        enum do
          Node.order(:name).collect {|p| [p.name, p.id]}
        end
      end
      filters [:node_id]
      exclude_fields :created_at, :id, :versions
    end

    edit do
      [:name, :state, :description, :node].each do |field|
        configure field do
          read_only true
        end
      end

      configure :versions do
        visible do
          bindings[:view]._current_user.role == "admin"
        end
      end

    end

    export do
      date_time_format_for :created_at, :updated_at
    end
  end

end
