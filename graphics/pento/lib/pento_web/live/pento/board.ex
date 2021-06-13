#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.Pento.Board do
  use Surface.LiveComponent
  alias PentoWeb.Pento.{Canvas, Palette, Shape}
  alias Pento.Game.{Board}
  import PentoWeb.Pento.Colors

  prop puzzle, :string
  data board, :any
  data shape, :any

  def update(%{puzzle: puzzle, id: id}, socket) do
    {:ok,
      socket
      |> assign_id(id)
      |> assign_puzzle(puzzle)
      |> assign_board()
      |> assign_shape()}
  end

  def assign_id(socket, id) do
    assign(socket, id: id)
  end

  def assign_puzzle(socket, puzzle) do
    assign(socket, puzzle: puzzle)
  end

  def assign_board(%{assigns: %{puzzle: puzzle}} = socket) do
    board = puzzle
            |> String.to_existing_atom
            |> Board.new
    assign(socket, board: board)
  end

  def assign_shape(%{assigns: %{board: board}} = socket) do
    shape = Board.to_shape(board)
    assign(socket, shape: shape)
  end


  def render(assigns) do
    ~H"""
    <div id="{{ @id }}">
      <Canvas viewBox="0 0 200 70">
        <Shape
          points={{ @shape.points }}
          fill= {{ color(@shape.color, Board.active?(@board, @shape.name)) }}
          name={{ @shape.name }} />
      </Canvas>
      <hr/>
      <Palette shape_names= {{ @board.palette }} />
    </div>
    """
  end
end
