#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.PentoLive do
  use Phoenix.LiveView
  alias Pento.Pentomino

  def mount(_params, _session, socket) do
    {:ok, assign(socket, pentomino: Pentomino.new)}
  end

  def render(assigns) do
    ~L"""
    <pre phx-window-keydown="keydown">
      <%= inspect @pentomino %>
    </pre>
    """
  end

def handle_event("keydown", %{"code" => "ArrowDown"}, socket) do
  {
    :noreply, 
    assign(socket, pentomino: Pentomino.down(socket.assigns.pentomino))
  }
end

def handle_event("keydown", %{"code" => "ArrowUp"}, socket) do
  {
    :noreply, 
    assign(socket, pentomino: Pentomino.up(socket.assigns.pentomino))
  }
end

def handle_event("keydown", %{"code" => "ArrowLeft"}, socket) do
  {
    :noreply, 
    assign(socket, pentomino: Pentomino.left(socket.assigns.pentomino))
  }
end

def handle_event("keydown", %{"code" => "ArrowRight"}, socket) do
  {
    :noreply, 
    assign(socket, pentomino: Pentomino.right(socket.assigns.pentomino))
  }
end

def handle_event("keydown", %{"code" => "Space"}, socket) do
  {
    :noreply, 
    assign(socket, pentomino: Pentomino.rotate(socket.assigns.pentomino))
  }
end

def handle_event("keydown", %{"code" => "ShiftLeft"}, socket) do
  {
    :noreply, 
    assign(socket, pentomino: Pentomino.next_shape(socket.assigns.pentomino))
  }
end

def handle_event("keydown", %{"code" => "Escape"}, socket) do
  {
    :noreply, 
    assign(socket, pentomino: Pentomino.flip(socket.assigns.pentomino))
  }
end



end
