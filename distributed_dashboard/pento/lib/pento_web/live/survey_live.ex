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
  alias Pento.{Catalog, Accounts, Survey}
  alias PentoWeb.Endpoint
  @survey_results_topic "survey_results"

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    {:ok,
     socket
     |> assign_user(token)
     |> assign_demographic()
     |> assign_products()}
  end


  @impl true
  def handle_info({:created_demographic, demographic}, socket) do
    {:noreply, handle_demographic_created(socket, demographic)}
  end


  @impl true
  def handle_info({:created_rating, updated_product, product_index}, socket) do
    {:noreply, handle_rating_created(socket, updated_product, product_index)}
  end


  def assign_user(socket, token) do
    assign_new(socket, :current_user, fn -> Accounts.get_user_by_session_token(token) end)
  end


  def assign_demographic(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :demographic, Survey.get_demographic_by_user(current_user))
  end


  def assign_products(%{assigns: %{current_user: current_user}} = socket) do
    assign(socket, :products, list_products(current_user))
  end

  defp list_products(user) do
    Catalog.list_products_with_user_ratings(user)
  end


  def handle_demographic_created(socket, demographic) do
    socket
    |> put_flash(:info, "Demographic created successfully")
    |> assign(:demographic, demographic)
  end


  def handle_rating_created(
         %{assigns: %{products: products}} = socket,
         updated_product,
         product_index
       ) do
    Endpoint.broadcast(@survey_results_topic, "rating_created", %{})

    socket
    |> put_flash(:info, "Rating submitted successfully")
    |> assign(
      :products,
      List.replace_at(products, product_index, updated_product)
    )
  end

end
