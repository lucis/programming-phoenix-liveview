#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule Pento.Game.Board do
  defstruct [active_pento: nil, completed_pentos: [], palette: [], points: []]
  alias Pento.Game.{Shape, Pentomino}

  def puzzles(), do: ~w[default wide widest medium tiny]a

  def new(palette, points) do
    %__MODULE__{palette: palette(palette), points: points}
  end

  def new(:tiny), do: new(:small, rect(5, 3))
  def new(:widest), do: new(:all, rect(20, 3))
  def new(:wide), do: new(:all, rect(15, 4))
  def new(:medium), do: new(:all, rect(12, 5))
  def new(:default), do: new(:all, rect(10, 6))

  def to_shape(board) do
    Shape.__struct__(color: :purple, name: :board, points: board.points)
  end

  def active?(board, shape_name) when is_binary(shape_name) do
    active?(board, String.to_existing_atom(shape_name))
  end
  def active?(%{active_pento: %{name: shape_name}}, shape_name), do: true
  def active?(_board, _shape_name), do: false

  defp rect(x, y) do
    for x <- 1..x, y <- 1..y, do: {x, y}
  end
  defp palette(:all), do: [:i, :l, :y, :n, :p, :w, :u, :v, :s, :f, :x, :t]
  defp palette(:small), do: [:u, :v, :p]
end
