#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentoWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers
  @doc """
  Renders a component inside the `PentoWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

  <%= live_modal @socket, PentoWeb.ProductLive.FormComponent,
  id: @product.id || :new,
  action: @live_action,
  product: @product,
  return_to: Routes.product_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, PentoWeb.ModalComponent, modal_opts)
  end
end
