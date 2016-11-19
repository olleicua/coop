class GamesController < ApplicationController

  before_action :authenticate_user!

  before_action except: :index do
    id = params[:id] || params[:game_id]
    if id
      @game = Game.find(id)
    else
      @game = Game.new
    end
  end

  def index
    @games = Game.all
  end

  def show
    if @game.joinable?
      render :join
    else
      render :show
    end
  end

  def new
  end

  def create
    @game.player_count = 2
    @game.assign_attributes(
      params.require(:game).permit(:canvas_height, :canvas_width, :player_count)
    )
    @game.canvas_width = @game.canvas_height if @game.canvas_width.nil?
    @game.initialize_image
    if @game.save
      @game.players.create(user: current_user)
      redirect_to @game
    else
      render :new
    end
  end

  def join
    # TODO check for validations
    @game.players.create(user: current_user) if @game.joinable?
    redirect_to @game
  end

  def move
    @player = @game.players.find_by(user_id: current_user.id)
    if @player
      @player.update(params.require(:move).permit(:row, :column, :color))
      # TODO make sure moves are only made on spaces that are currently black
      if @game.players.where(current_move: nil).any?
        if params[:format] == 'json'
          render json: { update: false }
        else
          flash[:notice] = 'Your move has been locked in'
          redirect_to @game
        end
      else
        @game.resolve_moves!
        if params[:format] == 'json'
          render json: { update: true }
        else
          redirect_to @game
        end
      end
    else
      flash[:alert] = 'You are observing this game'
      redirect_to @game
    end
  end

  def poll
    render json: {updated: @game.updated_at.to_i}
  end
end
