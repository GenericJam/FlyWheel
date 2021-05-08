defmodule FlyWheel.WheelTest do
  use ExUnit.Case
  alias FlyWheel.Wheel
  doctest Wheel

  test "without current_speed specified, defaults to 0" do
    flywheel = %Wheel{id: "flywheel_1"}

    assert flywheel.current_speed == 0
  end

  test ".create takes a map of parameters, builds a struct and persists" do
    flywheel_params = %{id: "flywheel_1"}

    assert {:ok, %Wheel{}} = Wheel.create(flywheel_params)
  end

  test ".get with an previously created id retrieves the struct" do
    id = "flywheel_1"

    Wheel.create(%{id: id})

    assert %Wheel{id: ^id} = Wheel.get(id)
  end

  test ".get with an id that hasn't been created" do
    assert nil == Wheel.get("unknown_id")
  end

  test ".all returns flywheel structs that have been created" do
    id = "flywheel_1"
    Wheel.create(%{id: id})

    assert [%Wheel{id: ^id}] = Wheel.all()
  end

  test ".set_current_speed/2" do
    id = "flywheel_1"
    Wheel.create(%{id: id})
    Wheel.set_current_speed(id, 5)

    assert %Wheel{current_speed: 5} = Wheel.get(id)
  end
end
