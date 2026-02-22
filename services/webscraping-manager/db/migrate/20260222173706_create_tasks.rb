class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :status, default: 'pending'
      t.string :url
      t.jsonb :result
      t.text :error_message
      t.datetime :concluded_at

      t.timestamps
    end
  end
end
