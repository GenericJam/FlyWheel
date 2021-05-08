defmodule FlyWheel.Wheel do
  @moduledoc """
  A flywheel has a speed
  """

  use GenServer

  alias FlyWheel.Wheel

  defstruct(id: nil, current_speed: 0, rated_speed: 10)

  def create(params) do
    start_link([], Map.merge(%Wheel{}, params))
    {:ok, Map.merge(%Wheel{}, params)}
  end

  @doc """
  Init callback
  """
  def init(%Wheel{} = state), do: {:ok, state}

  @doc """
  Start a User
  """
  def start_link(_, %Wheel{id: id} = state) do
    GenServer.start_link(__MODULE__, state, name: via_id(id))
  end

  @doc """
  Translate GenServer.call to send_sync
  """
  def send_sync(id, args_tuple), do: GenServer.call(via_id(id), args_tuple)

  @doc """
  Translate GenServer.cast to send_async
  """
  def send_async(id, args_tuple), do: GenServer.cast(via_id(id), args_tuple)

  def handle_call({:get_id}, _from, %{id: id} = state) do
    {:reply, state, state}
  end

  def handle_cast({:set_speed_value, speed_value}, state) do
    {:noreply, %Wheel{state | current_speed: speed_value}}
  end

  def handle_cast(
        {:add_speed_value, speed_value},
        %{
          current_speed: current_speed,
          rated_speed: rated_speed
        } = state
      )
      when speed_value + current_speed <= rated_speed do
    {:noreply, %Wheel{state | current_speed: current_speed + speed_value}}
  end

  def all() do
    Registry.select(:id, [{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.map(fn id ->
      send_sync(id, {:get_id})
    end)
  end

  def get(id) do
    case Registry.lookup(:id, "#{id}") do
      [] -> nil
      _ -> send_sync(id, {:get_id})
    end
  end

  def set_current_speed(id, speed_value) do
    send_async(id, {:set_speed_value, speed_value})
  end

  def add_speed(id, speed_value) do
    send_async(id, {:add_speed_value, speed_value})
  end

  defp via_id(id), do: {:via, Registry, {:id, "#{id}"}}
end
