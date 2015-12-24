class CreateCaptures < ActiveRecord::Migration
  def change
    create_table :captures do |t|
      t.belongs_to :user
      t.timestamps null: false

      t.string  :key,     null: false, length: 32
      t.text    :content, null: false
      t.integer :status,  default: 0

      t.index :user_id
      t.index [:user_id, :key], unique: true
    end
  end
end
