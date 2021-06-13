#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.UserActivityLive do
  use PentoWeb, :live_component
  alias PentoWeb.Presence
  @user_activity_topic "user_activity"

  def update(_assigns, socket) do
    {:ok,
     socket
     |> assign_user_activity()}
  end

  def assign_user_activity(socket) do
    presence_map = Presence.list(@user_activity_topic)

    user_activity =
      presence_map
      |> Enum.map(fn {product_name, _data} ->
        users =
          get_in(presence_map, [product_name, :metas])
          |> List.first()
          |> get_in([:users])

        {product_name, users}
      end)

    assign(socket, :user_activity, user_activity)
  end
end

