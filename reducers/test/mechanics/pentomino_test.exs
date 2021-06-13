#---
# Excerpted from "Programming Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/liveview for more book information.
#---
defmodule PentominoTest do
  use ExUnit.Case
  import Pento.Pentomino

  test "rename, rotate, flip and move a pentomino" do
    actual = 
      new()
      |> next_shape
      |> next_shape
      |> rotate
      |> rotate
      |> flip
      |> right
      |> right
      |> right
      |> down
    
    assert actual.name == :y
    assert actual.rotation == 180
    assert actual.reflected == true
    assert actual.location == {13, 11}
  end

  
  def check(pentomino, field, expected) do
    actual = Map.get(pentomino, field)
    assert actual == expected
    
    pentomino
  end
end
