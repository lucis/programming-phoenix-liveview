#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.Presence do
  use Phoenix.Presence,
    otp_app: :pento,
    pubsub_server: Pento.PubSub

  alias PentoWeb.Presence
  alias Pento.Accounts
  @user_activity_topic "user_activity"

  def track_user(pid, product, token) do
    user = Accounts.get_user_by_session_token(token)

    case Presence.get_by_key("user_activity", "testing") do
      [] ->
        Presence.track(pid, "user_activity", "testing", %{users: [%{email: "sophie@email.com"}]})

      %{metas: [%{users: active_users_for_product}]} ->
        Presence.update(pid, @user_activity_topic, product.name, %{
          users: [%{email: user.email} | active_users_for_product ]
        })
    end
  end
end
