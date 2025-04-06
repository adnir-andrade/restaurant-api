class AddUniqueConstraintToMenus < ActiveRecord::Migration[8.0]
  def change
    def change
      add_index :menus, [ 'LOWER(name)', :restaurant_id ], unique: true, name: 'index_menus_on_lower_name_and_restaurant_id'
    end
  end
end
