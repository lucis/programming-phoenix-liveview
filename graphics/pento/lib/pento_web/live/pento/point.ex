#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---

defmodule PentoWeb.Pento.Point do
  use Surface.Component

  @width 10

  prop x, :integer
  prop y, :integer
  prop fill, :string
  prop name, :string

  def render(assigns) do
    ~H"""
      <use
        xlink:href="#point"
        x="{{ convert(@x) }}"
        y="{{ convert(@y) }}"
        fill="{{ @fill }}" />
    """
  end

  defp convert(i) do
    (String.to_integer(i)-1) * @width + 2 * @width
  end
end
