#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.RatingLive.ShowComponent do
  use PentoWeb, :live_component

  def render_rating_stars(stars) do
    filled_stars(stars)
    |> Enum.concat(unfilled_stars(stars))
    |> Enum.join(" ")
  end

  def filled_stars(stars) do
    List.duplicate("<span class='fa fa-star checked'></span>", stars)
  end

  def unfilled_stars(stars) do
    List.duplicate("<span class='fa fa-star'></span>", 5 - stars)
  end
end
