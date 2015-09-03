class GroupAssignment < ActiveRecord::Base
  include GitHubPlan

  extend FriendlyId
  friendly_id :title, use: [:slugged, :finders]

  default_scope { where(deleted_at: nil) }

  has_one :group_assignment_invitation, dependent: :destroy, autosave: true

  has_many :group_assignment_repos, dependent: :destroy

  belongs_to :creator, class_name: User
  belongs_to :grouping
  belongs_to :organization

  validates :creator, presence: true

  validates :organization, presence: true

  validates :title, presence: true
  validates :title, uniqueness: { scope: :organization }

  validate :uniqueness_of_title_across_organization

  after_create :create_group_assignment_invitation

  alias_attribute :invitation, :group_assignment_invitation

  def private?
    !public_repo
  end

  def public?
    public_repo
  end

  def starter_code?
    starter_code_repo_id.present?
  end

  private

  def create_group_assignment_invitation
    GroupAssignmentInvitation.create(group_assignment_id: id)
  end

  def uniqueness_of_title_across_organization
    return unless Assignment.where(title: title, organization: organization).present?
    errors.add(:title, 'has already been taken')
  end
end
