defmodule Bitfeels do
  @moduledoc """
  Bitfeels keeps the contexts that define the domain and business logic.
  """

  @spec twitter_stream(binary, binary, binary) :: {:ok, pid} | {:error, :max_children} | {:error, term}
  def twitter_stream(user_name, twitter_track, twitter_filter_level \\ "none") do
    Bitfeels.StreamSupervisor.start_child(user_name, twitter_track, twitter_filter_level)
  end

  @spec all_streams() :: list(binary)
  def all_streams() do
    Registry.Streams
    |> Registry.select([{{:"$1", :_, :_}, [], [:"$1"]}])
    |> Enum.map(fn stream ->
      [user, track] = String.split(stream, "_")
      %{user: user, track: track}
    end)
  end

  @spec stop_stream(binary, binary) :: :ok | {:error, :not_found}
  def stop_stream(user, track) do
    case Registry.lookup(Registry.Streams, "#{user}_#{track}") do
      [{pid, _}] -> DynamicSupervisor.terminate_child(Bitfeels.StreamSupervisor, pid)
      [] -> {:error, :not_found}
    end
  end
end
