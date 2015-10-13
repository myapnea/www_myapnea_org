class Admin::Export < ActiveRecord::Base
  # Uploaders
  mount_uploader :file, ZipUploader

  # Callbacks
  after_create :start_export_in_background

  # Concerns
  include Forkable

  # Model Validation
  validates :user_id, presence: true

  # Model Relationships
  belongs_to :user

  # Model Methods

  def name
    created_at.strftime('%-d %B %Y, %-l:%M %p')
  end

  def percent
    return 0 if total_steps == 0 && %w(started failed).include?(status)
    total_steps > 0 ? current_step * 100 / total_steps : 100
  end

  private

  def number_of_steps
    exportable_users.count + 2
  end

  def start_export_in_background
    fork_process :start_export
  end

  def start_export
    update current_step: 0, total_steps: number_of_steps
    finalize_export generate_zip_file
  rescue => e
    export_failed e.message.to_s + e.backtrace.to_s
  end

  # Zip multiple files, or zip one file if it's part of the sheet uploaded
  # files, always zip folder
  def generate_zip_file
    filename = "myapnea-data-#{created_at.strftime('%Y%m%d%H%M')}"
    all_files = generate_all_files(filename)

    return if all_files.empty?

    # Create a zip file
    zipfile_name = File.join('tmp', 'exports', "#{filename}-#{Digest::SHA1.hexdigest(Time.zone.now.usec.to_s)[0..8]}.zip")
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      all_files.uniq.each do |location, input_file|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(location, input_file) if File.exist?(input_file) && File.size(input_file) > 0
      end
    end
    zipfile_name
  end

  def generate_all_files(filename)
    export_data(filename) + export_data_dictionary(filename) + export_sas(filename)
  end

  def export_data(filename)
    data_csv = File.join('tmp', 'exports', "#{filename}-#{created_at.strftime('%I%M%P')}-data.csv")
    write_data_csv(data_csv)
    [["#{data_csv.split('/').last}", data_csv]]
  end

  def export_data_dictionary(filename)
    dictionary_csv = File.join('tmp', 'exports', "#{filename}-#{created_at.strftime('%I%M%P')}-dictionary.csv")
    write_data_dictionary_csv(dictionary_csv)
    [["#{dictionary_csv.split('/').last}", dictionary_csv]]
  end

  def export_sas(filename)
    sas_file = File.join('tmp', 'exports', "#{filename}-#{created_at.strftime('%I%M%P')}.sas")
    write_sas(sas_file)
    [["#{sas_file.split('/').last}", sas_file]]
  end

  def finalize_export(export_file)
    if export_file
      export_succeeded export_file
    else
      export_failed 'No files were added to zip file.'
    end
  end

  def export_succeeded(export_file)
    update status: 'completed',
           file: File.open(export_file),
           file_created_at: Time.zone.now,
           current_step: total_steps
    notify_user!
  end

  def export_failed(details)
    update status: 'failed', details: details
  end

  def notify_user!
    UserMailer.export_ready(self).deliver_later if Rails.env.production? # ENV['emails_enabled'] == 'true'
  end

  def write_data_csv(data_csv)
    CSV.open(data_csv, 'wb') do |csv|
      row = %w(myapnea_id consented encounter)
      question_slugs = []
      surveys_answer_templates = []

      Survey.current.viewable.non_pediatric.includes(questions: [answer_templates: :answer_options]).each do |survey|
        survey.questions.each do |question|
          question.answer_templates.each do |at|
            slug = at.name
            question_slugs << slug
            surveys_answer_templates << [survey.id, question.id, at.id]
          end
        end
      end

      csv << (row + question_slugs)

      exportable_users.each do |user|
        encounters = ['baseline']
        encounters.each do |encounter|
          myapnea_id = 'MA%06d' % user.id
          row = [myapnea_id, (user.accepted_consent? ? '1' : '0'), encounter]
          surveys_answer_templates.each do |survey_id, question_id, answer_template_id|
            answer_session = user.answer_sessions.find_by_survey_id survey_id
            if answer_session
              values = AnswerValue.joins(:answer).where(answers: { answer_session_id: answer_session.id, question_id: question_id }).where(answer_template_id: answer_template_id).collect(&:raw_value)
              row << values.collect(&:to_s).sort.join(',')
            else
              row << nil
            end
          end
          csv << row
        end
        update current_step: current_step + 1
      end
    end
  end

  def write_data_dictionary_csv(dictionary_csv)
    CSV.open(dictionary_csv, 'wb') do |csv|
      csv << %w(folder id display_name type domain)

      Survey.viewable.includes(questions: [answer_templates: :answer_options]).each do |survey|
        survey.questions.each do |question|
          question.answer_templates.each do |at|
            slug = at.name
            display_name = at.text.to_s.chomp
            display_name = question.text_en if display_name.blank?

            answer_options = at.answer_options.order(:value).pluck(:value, :text)
            domain = answer_options.collect { |ao| "#{ao[0]}: #{ao[1]}" }.join(' | ')

            csv << [survey.slug,
                    slug,
                    display_name,
                    at.template_name,
                    domain
                   ]
          end
        end
      end
    end
    update current_step: current_step + 1
  end

  def write_sas(sas_file)
    @export_formatter = self

    erb_file = File.join('app', 'views', 'admin', 'exports', 'sas_export.sas.erb')

    File.open(sas_file, 'w') do |file|
      file.syswrite(ERB.new(File.read(erb_file)).result(binding))
    end
    update current_step: current_step + 1
  end

  def exportable_users
    User.include_in_exports_and_reports.order(:id)
  end
end