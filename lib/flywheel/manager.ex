defmodule FlyWheel.Manager do
  @moduledoc """
  Manager of flywheels
  """

  alias FlyWheel.Wheel

  def current_speed do
    Wheel.all()
    |> Enum.map(fn %{current_speed: current_speed} ->
      current_speed
    end)
    |> Enum.sum()
  end

  def export(speed) do
    Wheel.all()
    |> distribute(speed)

    :ok
  end

  def distribute(flywheels, speed) do
    flywheels_with_cap =
      flywheels
      |> Enum.filter(fn
        %{current_speed: rated_speed, rated_speed: rated_speed} -> false
        _ -> true
      end)

    group =
      flywheels_with_cap
      |> Enum.count()

    dist(flywheels_with_cap, speed, group)
  end

  def dist(flywheel_list, speed, group) when group >= speed do
    deliver(flywheel_list, 0..(group - 1), 1)
  end

  def dist(flywheel_list, speed, group) do
    speed_per_batt = div(speed, group)
    add_one_per_batt = rem(speed, group)

    deliver(flywheel_list, 0..(add_one_per_batt - 1), speed_per_batt + 1)
    deliver(flywheel_list, add_one_per_batt..(group - 1), speed_per_batt)
  end

  def deliver(_flywheel_list, 0..-1, _speed_per_batt) do
    :ok
  end

  def deliver(flywheel_list, range, speed_per_batt) do
    Enum.each(range, fn i ->
      send_speed(flywheel_list, i, speed_per_batt)
    end)
  end

  def send_speed(flywheel_list, index, speed_per_batt) do
    %{id: id} = flywheel_list |> Enum.at(index)
    Wheel.add_speed(id, speed_per_batt)
  end
end
