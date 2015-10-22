class Reaction < ActiveRecord::Base
  # Default Scope
  # Constants
  FORM_LIKE = 'like'
  FORM_DISLIKE = 'dislike'
  FORM_REQUEST = 'request_expert_comment'

  # Attribute related macros
  # Associations
  belongs_to :post
  belongs_to :user

  # Validations
  validates :post_id, presence: true

  # Callback
  # Other macros
  # Concerns
  include Deletable

  # Named scopes
  # Methods
end