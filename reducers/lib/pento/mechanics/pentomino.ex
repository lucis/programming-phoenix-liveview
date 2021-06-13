#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule Pento.Pentomino do
  alias Pento.Point
  @names [:i, :l, :y, :n, :p, :w, :u, :v, :s, :f, :x, :t]
  @middle {10, 10}
  
  defstruct [
    name: List.first(@names), 
    rotation: 0, 
    reflected: false,
    location: @middle
  ]

  def new(fields \\ []), do: __struct__(fields)
  
  def next_shape(p) do
    %{ p | name: next_name(p.name)}
  end
  
  defp next_name(name, names \\ @names) do
    result = 
      names
      |> Enum.drop_while(fn n -> n != name end)
      |> Enum.drop(1)
      |> List.first
      
    result || List.first(@names)
  end

  def rotate(%{rotation: degrees}=p) do
    %{ p | rotation: rotate(degrees)}
  end
  
  def rotate(270), do: 0
  def rotate(degrees), do: degrees + 90

  def flip(%{reflected: reflection}=p) do
    %{ p | reflected: not reflection}
  end

  def up(p) do
    %{ p | location: Point.move(p.location, {0, -1})}
  end

  def down(p) do
    %{ p | location: Point.move(p.location, {0, 1})}
  end

  def left(p) do
    %{ p | location: Point.move(p.location, {-1, 0})}
  end

  def right(p) do
    %{ p | location: Point.move(p.location, {1, 0})}
  end

  
  
end