class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.root? || user.can?(:read, record_class)
  end

  def show?
    user.root? || user.can?(:read, record_class)
  end

  def create?
    user.root? || user.can?(:create, record_class)
  end

  def update?
    user.root? || user.can?(:update, record_class)
  end

  def destroy?
    user.root? || user.can?(:destroy, record_class)
  end

  def edit?
    update?
  end

  def reopen?
    update?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end

    private
    attr_reader :user, :scope
  end

  private

  def record_class
    record.is_a?(Class) ? record : record.class
  end
end
