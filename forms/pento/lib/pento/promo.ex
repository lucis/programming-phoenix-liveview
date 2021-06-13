#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule Pento.Promo do
  alias Pento.Promo.Recipient

  def change_recipient(%Recipient{} = recipient, attrs \\ %{}) do
    Recipient.changeset(recipient, attrs)
  end

  def send_promo(recipient, attrs) do
    changeset =
      recipient
      |> change_recipient(attrs)
      |> Map.put(:action, :validate)

    case changeset.valid? do
      true ->
        recipient
        |> struct(changeset.changes)
        |> email_promo()
      false ->
        {:error, changeset}
    end
  end

  def email_promo(recipient) do
    IO.puts "Emailing promo code to #{recipient.email}..."
    {:ok, recipient}
  end
end
