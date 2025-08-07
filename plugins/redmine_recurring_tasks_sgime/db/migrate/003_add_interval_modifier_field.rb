class AddIntervalModifierField < ActiveRecord::Migration[7.0]
  def change
    change_table :recurring_tasks do |t|
      t.string :interval_modifier
    end
  end
end
