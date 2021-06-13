#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule Pento.Game.Shape do
  alias Pento.Game.Point

  defstruct color: :blue, name: :x, points: []

  defp color(:i), do: :dark_green
  defp color(:l), do: :green
  defp color(:y), do: :light_green
  defp color(:n), do: :dark_orange
  defp color(:p), do: :orange
  defp color(:w), do: :light_orange
  defp color(:u), do: :dark_gray
  defp color(:v), do: :gray
  defp color(:s), do: :light_gray
  defp color(:f), do: :dark_blue
  defp color(:x), do: :blue
  defp color(:t), do: :light_blue

  defp points(:i), do: [{3, 1}, {3, 2}, {3, 3}, {3, 4}, {3, 5}]
  defp points(:l), do: [{3, 1}, {3, 2}, {3, 3}, {3, 4}, {4, 4}]
  defp points(:y), do: [{3, 1}, {2, 2}, {3, 2}, {3, 3}, {3, 4}]
  defp points(:n), do: [{3, 1}, {3, 2}, {3, 3}, {4, 3}, {4, 4}]
  defp points(:p), do: [{3, 2}, {4, 3}, {3, 3}, {4, 2}, {3, 4}]
  defp points(:w), do: [{2, 2}, {2, 3}, {3, 3}, {3, 4}, {4, 4}]
  defp points(:u), do: [{2, 2}, {4, 2}, {2, 3}, {3, 3}, {4, 3}]
  defp points(:v), do: [{2, 2}, {2, 3}, {2, 4}, {3, 4}, {4, 4}]
  defp points(:s), do: [{3, 2}, {4, 2}, {3, 3}, {2, 4}, {3, 4}]
  defp points(:f), do: [{3, 2}, {4, 2}, {2, 3}, {3, 3}, {3, 4}]
  defp points(:x), do: [{3, 2}, {2, 3}, {3, 3}, {4, 3}, {3, 4}]
  defp points(:t), do: [{2, 2}, {3, 2}, {4, 2}, {3, 3}, {3, 4}]

  def new(name, rotation, reflected, location) do
    points =
      name
      |> points()
      |> Enum.map(&Point.prepare(&1, rotation, reflected, location))

    %__MODULE__{points: points, color: color(name), name: name}
  end
end
