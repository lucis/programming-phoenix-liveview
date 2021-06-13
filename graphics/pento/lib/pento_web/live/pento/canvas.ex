#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.Pento.Canvas do
  use Surface.Component

  prop viewBox, :string
  slot default, required: true

  def render(assigns) do
    ~H"""
    <svg viewBox="{{ @viewBox }}">
      <defs>
        <rect id="point" width="10" height="10" />
      </defs>
      <slot/>
    </svg>
    """
  end
end
