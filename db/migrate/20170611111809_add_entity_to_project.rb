class AddEntityToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :entity, :text, array:true, default: []
  end
end
