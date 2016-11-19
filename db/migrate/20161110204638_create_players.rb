class CreatePlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :players do |t|
      t.integer :game_id
      t.integer :user_id
      t.string :current_move
    end
    add_index :players, :game_id
    add_index :players, :user_id
  end
end
