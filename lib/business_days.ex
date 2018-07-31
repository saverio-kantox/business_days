defmodule BusinessDays do
  use GenServer

  require Logger

  @moduledoc """
  The examples assume that the holidays are passed in as

      %{
        "USD" => ~W[2018-01-01 2018-07-04 2018-12-25],
        "EUR" => ~W[2018-01-01 2018-08-15 2018-12-25 foo 2018-32-45],
        "AUD" => [~D[2018-01-01]],
        "GBP" => [{2018, 1, 1}]
      }

  invalid dates are logged on initialization
  """

  # Client

  @doc """
  Starts the BusinessDays server.
  """
  @typep dateable :: %Date{} | String.t() | :calendar.date()
  @spec start_link(data :: %{optional(String.t()) => list(dateable())}) :: {:ok, any}
  def start_link(data), do: GenServer.start_link(__MODULE__, data, name: __MODULE__)

  @doc """
  Returns a date that is `n` business days before the given date.

  ## Examples

      iex> BusinessDays.ago(~D[2018-07-28], 0)
      ~D[2018-07-27]

      iex> BusinessDays.ago(~D[2018-07-05], 1, ~W[USD])
      ~D[2018-07-03]

      iex> BusinessDays.ago(~D[2018-07-04], 0, ~W[USD])
      ~D[2018-07-03]
  """
  @spec ago(start :: dateable(), n :: integer(), names :: list(String.t())) :: %Date{}
  def ago(start, n, names \\ [])

  def ago(start, n, names) when n < 0,
    do: since(start, -n, names)

  def ago(start, n, names),
    do: days_p(start, n, names, -1)

  @doc """
  Returns a date that is `n` business days after the given date.

  ## Examples

      iex> BusinessDays.since(~D[2018-07-28], 0)
      ~D[2018-07-30]

      iex> BusinessDays.since(~D[2018-01-01], 0, ~W[USD])
      ~D[2018-01-02]
  """
  @spec since(%Date{}, integer(), list(String.t())) :: %Date{}
  def since(start, n, names \\ [])

  def since(start, n, names) when n < 0,
    do: ago(start, -n, names)

  def since(start, n, names),
    do: days_p(start, n, names, 1)

  @doc """
  Returns a set of the defined holidays for the given calendar(s). One can
  have a plain list using `Enum.into/2`

  ## Examples
      iex> BusinessDays.holidays(["AUD", "USD"])
      [~D[2018-01-01], ~D[2018-07-04], ~D[2018-12-25]]
  """
  @spec holidays(list(String.t())) :: list(%Date{})
  def holidays(names) do
    __MODULE__
    |> GenServer.call({:holidays, names})
    |> Enum.sort()
  end

  defp days_p(start, n, names, direction) when is_tuple(start),
    do: days_p(Date.from_erl!(start), n, names, direction)

  defp days_p(start, n, names, direction) when is_binary(start),
    do: days_p(Date.from_iso8601!(start), n, names, direction)

  defp days_p(start, n, names, direction) do
    GenServer.call(__MODULE__, {:days, start, n, names, direction})
  end

  @impl true
  def init(map), do: {:ok, fix_input(map)}

  @impl true
  def handle_call({:days, start, n, names, direction}, _, state) do
    {new_state, holidays} = read_holidays(names, state)
    {:reply, find_nth_business_day(holidays, start, n, direction), new_state}
  end

  @impl true
  def handle_call({:holidays, names}, _, state) do
    {new_state, holidays} = read_holidays(names, state)
    {:reply, holidays, new_state}
  end

  defp fix_input(%{} = map) do
    Map.new(map, fn {k, v} ->
      {MapSet.new([k]), v |> MapSet.new(&smart_date_or_log/1) |> MapSet.delete(nil)}
    end)
  end

  defp read_holidays(names, state) do
    s = MapSet.new(names)

    new_state =
      Map.put_new_lazy(state, s, fn ->
        state
        |> Map.take(Enum.map(names, fn c -> MapSet.new([c]) end))
        |> Map.values()
        |> Enum.reduce(MapSet.new(), &MapSet.union/2)
      end)

    {new_state, Map.get(new_state, s)}
  end

  defp find_nth_business_day(holidays, start, n, direction) do
    start
    |> Stream.iterate(&Date.add(&1, direction))
    |> Stream.reject(fn d -> MapSet.member?(holidays, d) end)
    |> Stream.reject(fn d -> Date.day_of_week(d) in [6, 7] end)
    |> Stream.drop(n)
    |> Stream.take(1)
    |> Enum.to_list()
    |> List.first()
  end

  defp smart_date(%Date{} = s), do: {:ok, s}
  defp smart_date({_, _, _} = s), do: Date.from_erl(s)
  defp smart_date(s) when is_binary(s), do: Date.from_iso8601(s)

  defp smart_date_or_log(s) do
    case smart_date(s) do
      {:ok, s} ->
        s

      {:error, reason} ->
        Logger.warn("#{reason} #{s}")
        nil
    end
  end
end
