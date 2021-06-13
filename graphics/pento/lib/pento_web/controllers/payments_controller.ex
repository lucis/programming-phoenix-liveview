#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.PaymentsController do
  use PentoWeb, :controller
  alias Pento.Catalog
  @product_sales_topic "product_sales"

  def create(conn, _params) do
    product_name =
      Catalog.product_names()
      |> Enum.random()

    dollar_amount = Enum.random(1..50)

    PentoWeb.Endpoint.broadcast(
      @product_sales_topic,
      "sale_complete",
      %{
        product_name: product_name,
        sales_dollar_amount: dollar_amount,
        timestamp: NaiveDateTime.local_now()
      }
    )

    html(
      conn,
      "<h1>broadcasted :sale_complete event!</h1><p>Product: #{product_name}</p><p>Dollar Amount: #{
        dollar_amount
      }</p>"
    )
  end
end

