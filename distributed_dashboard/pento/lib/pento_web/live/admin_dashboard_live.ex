#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.AdminDashboardLive do
  use PentoWeb, :live_view
  alias PentoWeb.{SurveyResultsLive, UserActivityLive, ProductSalesLive}
  alias PentoWeb.Endpoint
  @survey_results_topic "survey_results"
  @user_activity_topic "user_activity"
  @product_sales_topic "product_sales"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe(@survey_results_topic)
      Endpoint.subscribe(@user_activity_topic)
      Endpoint.subscribe(@product_sales_topic)
    end

    {:ok,
     socket
     |> assign(:survey_results_component_id, "survey-results")
     |> assign(:user_activity_component_id, "user-activity")
     |> assign(:product_sales_component_id, "product-sales")}
  end

  def handle_info(%{event: "rating_created"}, socket) do
    send_update(
      SurveyResultsLive,
      id: socket.assigns.survey_results_component_id)
    {:noreply, socket}
  end


  def handle_info(%{event: "presence_diff"}, socket) do
    send_update(
      UserActivityLive,
      id: socket.assigns.user_activity_component_id)
    {:noreply, socket}
  end


  def handle_info(%{event: "sale_complete", payload: payload}, socket) do
    send_update(ProductSalesLive,
      id: socket.assigns.product_sales_component_id,
      new_plot_point: %{
        category: payload.product_name,
        value: payload.sales_dollar_amount,
        timestamp: payload.timestamp
      }
    )

    {:noreply, socket}
  end
end
