class AddShortDescriptionToQuestionFlows < ActiveRecord::Migration[4.2]
  def change
    add_column :question_flows, :short_description_en, :string
    add_column :question_flows, :short_description_es, :string
  end
end
