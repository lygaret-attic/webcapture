class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.belongs_to :user
      t.timestamps null: false

      t.string :description, null: false, length: 512
      t.text   :template,    null: false
      t.text   :json,        null: false
    end
  end
end
