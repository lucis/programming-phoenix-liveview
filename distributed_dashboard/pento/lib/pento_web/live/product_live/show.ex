#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.ProductLive.Show do
  use PentoWeb, :live_view

  alias Pento.Catalog
  alias PentoWeb.Presence

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    {:ok, assign(socket, :user_token, token)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    product = Catalog.get_product!(id)
    maybe_track_user(product, socket)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:product, product)}
  end

  def maybe_track_user(
      product,
      %{assigns: %{live_action: :show, user_token: user_token}} = socket
      ) do
    if connected?(socket) do
      Presence.track_user(self(), product, user_token)
    end
  end

  def maybe_track_user(_product, _socket), do: nil

  defp page_title(:show), do: "Show Product"
  defp page_title(:edit), do: "Edit Product"
end
