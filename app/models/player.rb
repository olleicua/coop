class Player < ActiveRecord::Base
  belongs_to :game
  belongs_to :user

  MOVE_PATTERN = /(\d+) (\d+) (#[0f]{3})/

  # TODO: validate and guarantee in DB that game_id, user_id is unique

  validates :current_move,
            format: { with: MOVE_PATTERN, message: 'invalid move' },
            allow_nil: true

  %w[ row column color ].each do |move_aspect|

    define_method move_aspect do
      get_instance_variables_from_current_move
      instance_variable_get("@#{move_aspect}")
    end

    define_method "#{move_aspect}=" do |value|
      instance_variable_set("@#{move_aspect}", value)
      set_current_move_from_instance_variables
    end

  end

  private

  def get_instance_variables_from_current_move
    if MOVE_PATTERN =~ current_move
      @row = $1.to_i
      @column = $2.to_i
      @color = $3
    elsif current_move.present?
      raise "Cannot parse invalid move: #{current_move.inspect}"
    end
  end

  def set_current_move_from_instance_variables
    move = "#{row} #{column} #{color}"
    self.current_move = move if MOVE_PATTERN =~ move
  end
end