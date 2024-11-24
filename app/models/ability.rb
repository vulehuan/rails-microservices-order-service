class Ability
  include CanCan::Ability

  def initialize(current_user_role, current_user_id)
    can :create, Order

    if current_user_role == 'admin'
      can :manage, :all
    else
      can :manage, Order, user_id: current_user_id
      can :read, OrderStatusHistory, order: { user_id: current_user_id }
    end
  end
end
