#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.ModalComponent do
  use PentoWeb, :live_component

  @impl true
  def render(assigns) do
    ~L"""
    <div id="<%= @id %>" class="phx-modal"
      phx-capture-click="close"
      phx-window-keydown="close"
      phx-key="escape"
      phx-target="#<%= @id %>"
      phx-page-loading>

      <div class="phx-modal-content">
        <%= live_patch raw("&times;"), to: @return_to, class: "phx-modal-close" %>
        <%= live_component @socket, @component, @opts %>
      </div>
    </div>
    """
  end


  @impl true
  def handle_event("close", _, socket) do
    {:noreply, push_patch(socket, to: socket.assigns.return_to)}
  end

end
