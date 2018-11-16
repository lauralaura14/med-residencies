class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :name
      t.string :field
      t.text :content
      t.integer :applicant_id
    end
  end
end
