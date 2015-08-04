class AnswerSession < ActiveRecord::Base
  # Concerns
  include Deletable

  # Associations
  belongs_to :survey
  belongs_to :user
  belongs_to :child
  has_many :answers, -> { where deleted: false }
  has_many :reports

  # Validations
  validates_presence_of :survey_id, :encounter
  validates_uniqueness_of :survey_id, scope: [:encounter, :user_id, :child_id]

  # Model Methods
  def self.most_recent(survey_id, user_id)
    answer_sessions = AnswerSession.current.where(survey_id: survey_id, user_id: user_id).order(updated_at: :desc)
    answer_sessions.empty? ? nil : answer_sessions.first
  end

  def self.find_or_create(user, survey)
    answer_sessions = AnswerSession.current.where(user_id: user.id, survey_id: survey.id).order(updated_at: :desc)

    if answer_sessions.empty?
      AnswerSession.create(user_id: user.id, survey_id: survey.id)
    else
      answer_sessions.first
    end
  end

  def completed?
    answers.complete.count == survey.questions.count
  end

  def locked?
    unless self[:locked]
      update(locked: (answers.locked.count == survey.questions.count))
    end

    self[:locked]
  end

  def process_answer(question, response)
    answer = answers.where(question_id: question.id).first_or_initialize
    if answer.locked?
      nil
    else
      answer.update_response_value!(response)
      answer
    end
  end

  def lock
    answers.each do |answer|
      answer.update(state: "locked")
    end
  end

  def unlock!
    answers.each {|answer| answer.update(state: 'incomplete')}
    update(locked: false)
  end

  def applicable_questions
    # all questions in answer session's answers
    Question.joins(:answers).where(answers: { answer_session_id: self.id })
  end

  def percent_completed
    if survey.questions.count > 0
      (answers.complete.count * 100.0 / survey.questions.count).round
    else
      100
    end
  end

  def destroy
    update_column :deleted, true
    answers.each do |a|
      a.destroy
    end
  end

  def position
    self[:position] || survey.default_position
  end
end
