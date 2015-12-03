class AddKeys < ActiveRecord::Migration
  def change
    add_foreign_key "captures", "users", name: "captures_user_id_fk", on_delete: :cascade
  end
end
