class CreateJobSeekers < ActiveRecord::Migration[8.0]
  def change
    create_table :job_seekers do |t|
      t.string :name
      t.string :email, null: true
      t.string :phone_number, null: true

      t.timestamps
    end
  end
end
