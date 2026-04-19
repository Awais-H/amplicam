class ApplicationPolicy
  attr_reader :context, :record

  def initialize(context, record)
    @context = context
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def admin?
    context.role == "admin"
  end

  def reviewer?
    admin? || context.role == "reviewer"
  end

  def submitter?
    reviewer? || context.role == "submitter"
  end
end
