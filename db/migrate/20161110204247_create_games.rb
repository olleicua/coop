class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.integer :canvas_height, null: false
      t.integer :canvas_width, null: false
      t.integer :player_count, null: false
      t.binary :image
      t.text :options

      t.timestamps
    end
  end
end
