class RemoveMenuIdFromMenuItems < ActiveRecord::Migration[8.0]
  def change
    remove_reference :menu_items, :menu, foreign_key: true
  end
end
