class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :create, :update, :to => :write

    can :access, :rails_admin   # grant access to rails_admin
    can :dashboard              # grant access to the dashboard
    can :read, :all
    can :node_ports, :all
    can :customer_ports, :all
    can :export, :all
    can :update, Port
    case user.role
      when "admin"
        can :manage, :all             # allow admins to do anything
      when "moderator"
        can :manage, [Location, Node, Zte, Dlink, Cisco, Comment, Customer]
        can :update, User, role: %w(moderator engineer banned)
        can :history, Port
        can :update_ports_info, :all
      when "engineer"
        can :update, User, id: user.id
        cannot :update, Port, reserved: true
        can :write, Customer
        can :create, Comment
        can :edit, Comment, user_id: user.id
      when "guest"
        cannot :update, Port
      when "banned"
        cannot :dashboard
    end

    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
