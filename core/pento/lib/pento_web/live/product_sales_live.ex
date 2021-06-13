#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.ProductSalesLive do
  use PentoWeb, :live_component
  use PentoWeb, :chart_live
  alias Pento.Catalog

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_product_names()
     |> assign_dataset()
     |> assign_chart()
     |> assign_chart_svg()}
  end

  defp assign_product_names(socket) do
    assign(socket, :product_names, Catalog.product_names())
  end

  defp assign_dataset(
         %{
           assigns: %{
             product_names: product_names,
             dataset: dataset,
             new_plot_point: new_plot_point
           }
         } = socket
       ) do
    assign(
      socket,
      :dataset,
      update_scatter_plot_dataset(product_names, dataset, new_plot_point)
    )
  end


  defp assign_dataset(%{assigns: %{product_names: product_names}} = socket) do
    assign(socket, :dataset, new_scatter_plot_dataset(product_names))
  end

  defp assign_chart(%{assigns: %{dataset: dataset, product_names: product_names}} = socket) do
    socket
    |> assign(:chart, make_scatter_plot_chart(dataset, product_names))
  end

  def assign_chart_svg(%{assigns: %{chart: chart}} = socket) do
    socket
    |> assign(
      :chart_svg,
      render_scatter_plot_chart(chart, title(), subtitle(), x_axis(), y_axis())
    )
  end

  defp title do
    "Product Sales"
  end

  defp subtitle do
    "dollar sales over time"
  end

  defp x_axis do
    "time"
  end

  defp y_axis do
    "sales in dollars"
  end
end
