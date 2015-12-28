RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      only ['Customer', 'Comment']
    end
    export
    bulk_delete
    show
    edit do
      only ['Port', 'Customer', 'Comment']
    end
    delete do
      only ['Customer', 'Comment']
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
  end

  %w(Node Cisco Zte Dlink).each do |imodel|
    config.model "#{imodel}" do
      list do
        exclude_fields :created_at, :updated_at
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

    show do
    end
  end
end
