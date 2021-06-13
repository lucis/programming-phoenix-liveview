#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.Pento.Palette do
  use Surface.Component
  alias PentoWeb.Pento.{Shape, Canvas}
  alias Pento.Game.Pentomino
  import PentoWeb.Pento.Colors

  prop shape_names, :list
  data shapes, :list

  def update(%{shape_names: shape_names}, socket) do
    shapes =
      shape_names
      |> Enum.with_index
      |> Enum.map(&pentomino/1)

    {:ok, assign(socket, shapes: shapes)}
  end
  defp pentomino({name, i}) do
    {x, y} = {rem(i, 6) * 4 + 3, div(i, 6) *5 + 3}
    Pentomino.new(name: name, location: {x, y})
    |> Pentomino.to_shape
  end

  def render(assigns) do
    ~H"""
    <Canvas viewBox="0 0 500 125">
      <Shape :for= {{ shape <- @shapes}}
        points={{ shape.points }}
        fill={{ color(shape.color) }}
        name={{ shape.name }} />
    </Canvas>
    """
  end
end
