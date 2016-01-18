require File.join(Rails.root, "lib", "rails_admin", "update_ports_info")
require File.join(Rails.root, "lib", "rails_admin", "node_ports")
require File.join(Rails.root, "lib", "rails_admin", "customer_ports")

PaperTrail.config.version_limit = 5

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

  config.model PaperTrail::Version do
    list do
      items_per_page 36
    end
  end

  config.excluded_models << "PaperTrail::VersionAssociation"
  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export do
      only ['Node', 'Zte', 'Dlink', 'Cisco', 'Iskratel', 'Port', 'Customer']
    end
    bulk_delete do
      only ['Customer', 'Port', 'User', 'Location', 'Comment']
    end
    show
    edit
    delete do
      only ['Customer', 'Port', 'User', 'Location', 'Comment']
    end

    # Custom actions
    node_ports do
      only ['Node', 'Zte', 'Dlink', 'Cisco', 'Iskratel']
    end
    customer_ports do
      only ['Customer']
    end
    update_ports_info do
      only ['Node', 'Zte', 'Dlink', 'Cisco', 'Iskratel']
    end

    show_in_app

    # With an audit adapter, you can add:
    history_index do
      only ['Port']
    end
    history_show do
      only ['Port']
    end

  end

  config.model 'User' do
    visible do
      # controller bindings is available here. Example:
      %w(admin moderator).include? bindings[:controller].current_user.role
    end
    list do
      fields :email, :role do; end
      fields :last_sign_in_ip,  :sign_in_count, :current_sign_in_at, :current_sign_in_ip, :remember_created_at, :created_at, :updated_at, :auth_token do
        visible do
          %w(admin).include? bindings[:view]._current_user.role
        end
      end
    end

    export do
      field :id
      field :email
      field :sign_in_count
      field :last_sign_in_ip
      field :last_sign_in_at
      field :created_at
      field :updated_at
    end

    create do
      field :email
      fields :password, :password_confirmation do
        visible do
          %w(admin moderator).include? bindings[:view]._current_user.role
        end
      end
      field :role, :enum do
        enum do
          if bindings[:view]._current_user.role == "moderator"
            User::ROLES - [:admin]
          elsif bindings[:view]._current_user.role == "admin"
            User::ROLES
          end
        end
        visible do
          %w(admin moderator).include? bindings[:view]._current_user.role
        end
      end
    end

    edit do
      field :email do
        read_only do
          %w(admin).exclude? bindings[:view]._current_user.role
        end
      end
      fields :password, :password_confirmation do
        visible do
          %w(admin).include? bindings[:view]._current_user.role
        end
      end
      field :role, :enum do
        enum do
          if bindings[:view]._current_user.role == "moderator"
            User::ROLES - [:admin]
          elsif bindings[:view]._current_user.role == "admin"
            User::ROLES
          end
        end
        visible do
          %w(admin moderator).include? bindings[:view]._current_user.role
        end
      end
    end

    show do
      field :email
      fields :role, :last_sign_in_ip, :remember_created_at, :sign_in_count, :current_sign_in_at, :current_sign_in_ip, :created_at, :updated_at, :auth_token do
        visible do
          %w(admin).include? bindings[:view]._current_user.role
        end
      end
    end
  end

  %w(Node Cisco Zte Dlink Iskratel).each do |imodel|
    config.model "#{imodel}" do
      list do
        # scopes [nil, :without_ports]
        configure :location do
          searchable [:address, :id]
        end
        filters [:location]
        exclude_fields :created_at, :updated_at, :id
      end

      edit do
        exclude_fields :ports
      end
    end
  end

  config.model 'Location' do
    list do
      exclude_fields :created_at, :updated_at, :id
    end
  end

  config.model 'Customer' do
    list do
      configure :account do
        column_width 160
      end 
      scopes [:with_ports, nil]
      exclude_fields :created_at, :updated_at, :id
    end

    edit do
      exclude_fields :ports
    end
  end

  config.model PaperTrail::Version do
    navigation_label 'Історія'
    label 'версія'
    label_plural 'версії'
  end

  config.model PaperTrail::VersionAssociation do
    navigation_label 'Історія'
  end

  config.model 'Comment' do
    visible do
      # controller bindings is available here.
      %w(admin).include? bindings[:controller].current_user.role
    end
    edit do
      field :body do; end
      field :port_id do
        hide
      end
      field :user_id, :hidden do
        default_value do
          bindings[:view]._current_user.id
        end
      end
    end
  end

  config.model 'Port' do
    list do
      scopes [nil, :reserved, :not_reserved]
      items_per_page 36
      field :id do
        sort_reverse false   # will sort id increasing ('asc') first ones first (default is last ones first)
        visible do
          %w(admin).include? bindings[:view]._current_user.role
        end
      end
      field :name do; end
      field :state do
        column_width 90
      end
      field :description do; end
      field :node do; end
      field :node_id, :enum do
        label 'Вибір комутатора'
        help 'Please select Node'
        enum do
          Node.order(:name).collect {|p| [p.name, p.id]}
        end
        visible false
        pretty_value do
          Node.find(bindings[:object].node_id).ip
        end
      end
      field :customer do; end
      field :comments do; end
      include_all_fields
      filters [:node_id]
      exclude_fields :created_at, :versions
    end

    edit do
      group :read do
        label "Додаткова інформація"
        active false
      end
      [:name, :state, :description, :node].each do |field|
        configure field do
          read_only true
          group :read
        end
      end
      include_all_fields
      configure :versions do
        visible do
          %w(admin).include? bindings[:view]._current_user.role
        end
      end
    end

    show do
      configure :versions do
        visible do
          %w(admin).include? bindings[:view]._current_user.role
        end
      end
    end

  end

end
