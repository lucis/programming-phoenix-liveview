#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.RatingLive.IndexComponent do
  use PentoWeb, :live_component
  def ratings_complete?(products) do
    Enum.all?(products, fn product ->
      length(product.ratings) == 1
    end)
  end
end
