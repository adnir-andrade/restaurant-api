class AddCaseInsensitiveUniqueIndexToMenuItemsName < ActiveRecord::Migration[8.0]
  def change
    add_index :menu_items, 'LOWER(name)', unique: true, name: 'index_menu_items_on_lower_name'
  end
end
