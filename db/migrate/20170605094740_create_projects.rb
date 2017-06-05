class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.text :title
      t.text :content
      t.references :user, foreign_key: true
      t.string :subject, array: true
      t.string :theme, array: true
      t.text :summary
      t.text :keywords, array: true

      t.timestamps
    end
  end
end
