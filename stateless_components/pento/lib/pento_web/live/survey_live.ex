#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.SurveyLive do
  use PentoWeb, :live_view
  alias Pento.Accounts

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    {:ok,
     socket
     |> assign_user(token)}
  end

  def assign_user(socket, token) do
    assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token(token)
    end)
  end
end
