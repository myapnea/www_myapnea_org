class CreateForemPosts < ActiveRecord::Migration[4.2]
  def change
    create_table :forem_posts do |t|
      t.integer :topic_id
      t.text :text
      t.integer :user_id
      t.timestamps
    end
  end
end
