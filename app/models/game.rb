class Game < ActiveRecord::Base
  has_many :players

  validates :canvas_height, presence: true
  validates :canvas_width, presence: true
  validates :player_count, presence: true
  validate :image_size_is_correct

  def joinable?
    players.count < player_count
  end

  COLORS = %w[ #000 #00f #0f0 #0ff #f00 #f0f #ff0 #fff ]

  def get_pixel(row, column)
    COLORS[image[(row * canvas_width) + column].ord]
  end

  def set_pixel(row, column, color)
    image[(row * canvas_width) + column] = (COLORS.index(color) || 0).chr
  end

  def resolve_moves!
    if players.where(current_move: nil).any?
      raise 'Cannot resolve moves, still waiting on one or more players'
    else
      # TODO make sure moves are only made on spaces that are currently black
      moves = {}
      players.each do |player|
        if moves[[player.row, player.column]].nil?
          moves[[player.row, player.column]] = player.color
        elsif moves[[player.row, player.column]] != player.color
          moves[[player.row, player.column]] = '#000'
        end
      end
      moves.each_pair do |(row, column), color|
        set_pixel(row, column, color)
      end
      save!
      players.update_all(current_move: nil)
    end
  end

  def initialize_image
    self.image = 0.chr * canvas_width * canvas_height
  end

  def describe
    "#{canvas_height}x#{canvas_width} game with #{players.count}/#{player_count} players"
  end

  private

  def image_size_is_correct
    if image.size != canvas_width * canvas_height
      errors.add(:image, "must have the expected dimentions")
    end
  end
end
