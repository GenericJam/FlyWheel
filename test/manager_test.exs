defmodule FlyWheel.ManagerTest do
  use ExUnit.Case
  alias FlyWheel.Wheel
  alias FlyWheel.Manager
  doctest Manager

  test ".current_speed returns the sum of all asset's current_speed" do
    first_flywheel = "flywheel_1"
    Wheel.create(%{id: first_flywheel, current_speed: 8})
    second_flywheel = "flywheel_2"
    Wheel.create(%{id: second_flywheel, current_speed: 3})

    assert Manager.current_speed() == 11
  end

  test ".export updates assets setpoint" do
    id = "flywheel_1"
    Wheel.create(%{id: id})

    assert Manager.current_speed() == 0

    Manager.export(5)

    assert %Wheel{current_speed: 5} = Wheel.get(id)
    assert Manager.current_speed() == 5
  end

  @tag :skip
  test ".export updates assets setpoint respecting rated_speed" do
    id = "flywheel_1"
    Wheel.create(%{id: id})
    Manager.export(20)
    assert %Wheel{current_speed: 10} = Wheel.get(id)
    assert Manager.current_speed() == 10
  end

  @tag :skip
  test ".export with multiple flywheels disperses load across flywheels" do
    first_flywheel = "flywheel_1"
    Wheel.create(%{id: first_flywheel})
    second_flywheel = "flywheel_2"
    Wheel.create(%{id: second_flywheel})

    Manager.export(10)

    assert %Wheel{current_speed: 5} = Wheel.get(first_flywheel)
    assert %Wheel{current_speed: 5} = Wheel.get(second_flywheel)

    assert Manager.current_speed() == 10
  end

  test ".export delivers additional speed to grid" do
    first_flywheel = "flywheel_1"
    Wheel.create(%{id: first_flywheel, current_speed: 8})
    second_flywheel = "flywheel_2"
    Wheel.create(%{id: second_flywheel, current_speed: 3})

    Manager.export(2)
    Process.sleep(1)
    assert %Wheel{current_speed: 9} = Wheel.get(first_flywheel)
    assert %Wheel{current_speed: 4} = Wheel.get(second_flywheel)
  end

  test ".export delivers additional speed to grid with maxed flywheel" do
    third_flywheel = "flywheel_3"
    Wheel.create(%{id: third_flywheel, current_speed: 10})
    fourth_flywheel = "flywheel_4"
    Wheel.create(%{id: fourth_flywheel, current_speed: 3})
    fifth_flywheel = "flywheel_5"
    Wheel.create(%{id: fifth_flywheel, current_speed: 3})

    Manager.export(3)

    Process.sleep(1)
    assert %Wheel{current_speed: 10} = Wheel.get(third_flywheel)
    assert %Wheel{current_speed: 4} = Wheel.get(fourth_flywheel)
    assert %Wheel{current_speed: 5} = Wheel.get(fifth_flywheel)
  end
end
