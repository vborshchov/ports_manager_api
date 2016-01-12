require File.join(Rails.root, "lib", "rails_admin", "without_ports")
require File.join(Rails.root, "lib", "rails_admin", "update_ports_info")
require File.join(Rails.root, "lib", "rails_admin", "node_ports")
require File.join(Rails.root, "lib", "rails_admin", "customer_ports")
require File.join(Rails.root, "lib", "rails_admin", "reserved_ports")
# require File.join(Rails.root, "lib", "rails_admin", "unreserved_ports")

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
      only ['Node', 'Zte', 'Dlink', 'Cisco', 'Port', 'Customer']
    end
    bulk_delete
    show
    edit
    delete

    # Custom actions
    without_ports do
      only ['Node', 'Zte', 'Dlink', 'Cisco']
    end
    node_ports do
      only ['Node', 'Zte', 'Dlink', 'Cisco']
    end
    customer_ports do
      only ['Customer']
    end
    update_ports_info do
      only ['Node', 'Zte', 'Dlink', 'Cisco']
    end
    reserved_ports do
      only ['Port']
    end
    # unreserved_ports do
    #   only ['Port']
    # end


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
      field :email
      fields :last_sign_in_ip, :remember_created_at, :sign_in_count, :current_sign_in_at, :current_sign_in_ip, :created_at, :updated_at, :auth_token do
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
            %w(moderator engineer banned)
          elsif bindings[:view]._current_user.role == "admin"
            %w(admin moderator engineer banned)
          end
        end
        visible do
          %w(admin moderator).include? bindings[:view]._current_user.role
        end
      end
    end

    edit do
      field :email
      fields :password, :password_confirmation do
        visible do
          %w(admin).include? bindings[:view]._current_user.role
        end
      end
      field :role, :enum do
        enum do
          if bindings[:view]._current_user.role == "moderator"
            %w(moderator engineer banned)
          elsif bindings[:view]._current_user.role == "admin"
            %w(admin moderator engineer banned)
          end
        end
        visible do
          %w(admin moderator).include? bindings[:view]._current_user.role
        end
      end
    end
  end

  %w(Node Cisco Zte Dlink).each do |imodel|
    config.model "#{imodel}" do
      list do
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
      # controller bindings is available here. Example:
      %w(admin).include? bindings[:controller].current_user.role
    end
    edit do
      field :body do; end
      field :user_id, :hidden do
        default_value do
          bindings[:view]._current_user.id
        end
      end
      exclude_fields :port
    end
  end

  config.model 'Port' do
    list do
      items_per_page 36
      configure :id do
        sort_reverse false   # will sort id increasing ('asc') first ones first (default is last ones first)
        visible do
          %w(admin).include? bindings[:view]._current_user.role
        end
      end

      # This config lead to problem with links in index view
      # Links to related nodes disappear when user "go" to another page and when come back
      # But when page was refresh link appear again
      #
      # configure :node do
      #   pretty_value do
      #     path = bindings[:view].show_path(model_name: 'node', id: bindings[:object].node_id)
      #     (bindings[:view].tag(:a, href: path, title: bindings[:object].node.ip) << value.name).html_safe
      #   end
      # end
      configure :node_id, :enum do
        label 'Вибір комутатора'
        help 'Please select Node'
        enum do
          Node.order(:name).collect {|p| [p.name, p.id]}
        end
        visible do
          %w(admin).include? bindings[:view]._current_user.role
        end
        pretty_value do
          Node.find(bindings[:object].node_id).ip
        end
      end
      filters [:node_id]
      exclude_fields :created_at, :versions
    end
    nested do
      configure :comments do
        hide
      end
    end
    edit do
      [:name, :state, :description, :node].each do |field|
        configure field do
          read_only true
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
