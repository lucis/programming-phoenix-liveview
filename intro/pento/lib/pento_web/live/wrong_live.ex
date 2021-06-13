#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  def mount(_params, _session, socket) do
    {
      :ok,
      assign(
        socket,
        score: 0,
        message: "Guess a number."
      )
    }
  end

  def render(assigns) do
    ~L"""
    <h1>Your score: <%= @score %></h1>
    <h2>
      <%= @message %>
    </h2>
    <h2>
      <%= for n <- 1..10 do %>
        <a href="#" phx-click="guess" phx-value-number="<%= n %>"><%= n %></a>
      <% end %>
    </h2>
    """
  end

  def time() do
     DateTime.utc_now |> to_string
  end

  def handle_event("guess", %{"number" => guess}=data, socket) do
    IO.inspect data
    message = "Your guess: #{guess}. Wrong. Guess again. "
    score = socket.assigns.score - 1

    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score)}
  end
end
