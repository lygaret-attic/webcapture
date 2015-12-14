class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.belongs_to :user
      t.timestamps null: false

      t.string :key,         null: false, length: 32
      t.text   :template,    null: false
      t.text   :properties

      t.index :user_id
      t.index [:user_id, :key], unique: true
    end
  end
end
