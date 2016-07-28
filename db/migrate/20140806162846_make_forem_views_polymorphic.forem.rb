class MakeForemViewsPolymorphic < ActiveRecord::Migration[4.2]
  def up
    rename_column :forem_views, :topic_id, :viewable_id
    add_column :forem_views, :viewable_type, :string
  end

  def down
    remove_column :forem_views, :viewable_type
    rename_column :forem_views, :viewable_id, :topic_id
  end
end
