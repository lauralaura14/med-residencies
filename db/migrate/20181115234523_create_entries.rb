class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :name
      t.string :number
      t.text :content
      t.integer :applicant_id
    end
  end
end
