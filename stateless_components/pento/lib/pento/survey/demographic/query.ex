#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule Pento.Survey.Demographic.Query do
  import Ecto.Query
  alias Pento.Survey.Demographic

  def base, do: Demographic

  def for_user(query \\ base(), user) do
    query
    |> where([d], d.user_id == ^user.id)
  end
end
