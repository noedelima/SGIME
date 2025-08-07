class AddRecurSubtasksField < ActiveRecord::Migration[7.0]
  def change
    change_table :recurring_tasks do |t|
      t.boolean :recur_subtasks
    end
  end
end
