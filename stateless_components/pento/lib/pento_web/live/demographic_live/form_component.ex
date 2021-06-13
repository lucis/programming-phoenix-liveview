#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.DemographicLive.FormComponent do
  use PentoWeb, :live_component
  alias Pento.Survey
  alias Pento.Survey.Demographic

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_demographic()
     |> assign_changeset()}
  end

  def assign_demographic(%{assigns: %{user: user}} = socket) do
    assign(socket, :demographic, %Demographic{user_id: user.id})
  end

  def assign_changeset(%{assigns: %{demographic: demographic}} = socket) do
    assign(socket, :changeset, Survey.change_demographic(demographic))
  end
end
