class CreateRecurringTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :recurring_tasks do |t|
      t.integer :current_issue_id
      t.boolean :fixed_schedule
      t.integer :interval_number
      t.string :interval_unit
    end
  end
end
