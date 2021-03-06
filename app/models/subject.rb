# frozen_string_literal: true

# Associates a user to a study as a study participant. Tracks consent and
# assigned subject code.
class Subject < ApplicationRecord
  # Uploaders
  mount_uploader :overview_report_pdf, PDFUploader

  # Concerns
  include Latexable
  include Reportable

  # Scopes
  scope :consented, -> { where.not(consented_at: nil).where(consent_revoked_at: nil) }
  scope :consent_revoked, -> { where.not(consented_at: nil, consent_revoked_at: nil) }

  # Validations
  validates :user_id, uniqueness: { scope: :project_id }

  # Relationships
  belongs_to :user
  belongs_to :project
  has_many :subject_surveys

  # Methods

  def consented?
    !consented_at.nil? && consent_revoked_at.nil?
  end

  def consent_revoked?
    !consented_at.nil? && !consent_revoked_at.nil?
  end

  def revoke_consent!
    update(consent_revoked_at: Time.zone.now)
  end

  # This method is only for external projects (that don't have Slice surveys).
  def recruited?
    !recruited_at.nil?
  end

  def linked?
    slice_subject_id.present?
  end

  def find_or_create_remote_subject!
    if linked?
      load_remote_subject
    else
      create_remote_subject!
      create_baseline_event!
    end
  end

  def create_remote_subject!
    params = {
      subject: {
        subject_code: project.generate_subject_code,
        site_id: project.slice_site_id
      }
    }
    (json, status) = Slice::JsonRequest.post("#{project.project_url}/subjects.json", params)
    load_subject_from_json(json, status)
    # link_subject
  end

  def load_remote_subject
    (json, status) = Slice::JsonRequest.get("#{project.project_url}/subjects/#{slice_subject_id}.json")
    load_subject_from_json(json, status)
  end

  def load_subject_from_json(json, status)
    return unless status.is_a?(Net::HTTPSuccess)
    return unless json
    update(
      slice_subject_id: json["id"],
      slice_subject_code_cache: json["subject_code"]
    )
    # @json = json
    # root_attributes.each do |attribute|
    #   send("#{attribute}=", json[attribute.to_s])
    # end
  end

  def create_baseline_event!
    return unless linked?
    params = { event_id: project.slice_baseline_event.presence || "baseline" } # Event.first.slug
    (json, status) = Slice::JsonRequest.post("#{project.project_url}/subjects/#{slice_subject_id}/events.json", params)
    load_events_from_json(json, status)
  end

  def subject_events
    @subject_events ||= begin
      load_subject_events
    end
  end

  def load_subject_events
    return [] unless linked?
    (json, status) = Slice::JsonRequest.get("#{project.project_url}/subjects/#{slice_subject_id}/events.json")
    load_events_from_json(json, status)
  end

  def load_events_from_json(json, status)
    return [] unless status.is_a?(Net::HTTPSuccess)
    return [] unless json
    json.collect do |subject_event|
      Slice::SubjectEvent.new(subject_event)
    end
  end

  def next_survey
    @next_survey ||= begin
      event = subject_events.find { |se| !se.complete?(self) }
      event&.event_designs&.find { |ed| !ed.complete?(self) }
    end
  end

  def resume_event_survey(event, design)
    Slice::JsonRequest.get("#{project.project_url}/subjects/#{slice_subject_id}/surveys/#{event}/#{design}/resume.json")
  end

  def page_event_survey(event, design, page)
    Slice::JsonRequest.get("#{project.project_url}/subjects/#{slice_subject_id}/surveys/#{event}/#{design}/#{page}.json")
  end

  def submit_response_event_survey(event, design, page, design_option_id, response, remote_ip)
    params = { _method: "patch", design_option_id: design_option_id, response: response, remote_ip: remote_ip }
    Slice::JsonRequest.post("#{project.project_url}/subjects/#{slice_subject_id}/surveys/#{event}/#{design}/#{page}.json", params)
  end

  def review_event_survey(event, design)
    params = { subject_id: slice_subject_id }
    Slice::JsonRequest.get("#{project.project_url}/reports/review/#{event}/#{design}.json", params)
  end

  def report_event_survey(event, design)
    params = { subject_id: slice_subject_id }
    Slice::JsonRequest.get("#{project.project_url}/reports/#{event}/#{design}.json", params)
  end

  def data(data_points)
    params = { data_points: data_points }
    (json, status) = Slice::JsonRequest.get("#{project.project_url}/subjects/#{slice_subject_id}/data.json", params)
    return unless status.is_a?(Net::HTTPSuccess)
    json
  end

  # Print Consent
  def latex_partial(partial)
    File.read(File.join("app", "views", "subjects", "latex", "_#{partial}.tex.erb"))
  end

  def generate_overview_report_pdf!(data)
    jobname = "overview_report"
    temp_dir = Dir.mktmpdir
    temp_tex = File.join(temp_dir, "#{jobname}.tex")
    write_tex_file(temp_tex, data)
    self.class.compile(jobname, temp_dir, temp_tex)
    temp_pdf = File.join(temp_dir, "#{jobname}.pdf")
    update overview_report_pdf: File.open(temp_pdf, "r"), overview_report_pdf_file_size: File.size(temp_pdf) if File.exist?(temp_pdf)
  ensure
    # Remove the directory.
    FileUtils.remove_entry temp_dir
  end

  def write_tex_file(temp_tex, data)
    # Needed by binding
    @project = project
    @subject = self
    @data = data
    File.open(temp_tex, "w") do |file|
      file.syswrite(ERB.new(latex_partial("header")).result(binding))
      file.syswrite(ERB.new(latex_partial("overview_report")).result(binding))
      file.syswrite(ERB.new(latex_partial("footer")).result(binding))
    end
  end
end
