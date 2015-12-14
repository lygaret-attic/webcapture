class AddTemplateFk < ActiveRecord::Migration
  def change
    add_foreign_key "templates", "users", name: "templates_user_id_fk", on_delete: :cascade
  end
end
