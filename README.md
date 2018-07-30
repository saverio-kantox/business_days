# BusinessDays

A neat library to do business days intervals given a set of calendars.


## Usage

Initalize the server with a map of holiday calendars:

    BusinessDays.start_link(%{
      "USD" => [{2018, 4, 7}, "2018-12-25", ~D[2018-01-01]],
      "other" => ~W[2018-04-07 2018-10-01]
    })

The dates in the calendars can be plain strings, Date objects or erlang
date-like tuples. Any non-conformant element of a calendar will be logged
and skipped.

Now you can calculate forwards and backwards intervals:

    iex> BusinessDays.since(~D[2018-07-03], 1, ~W[USD])
    ~D[2018-07-03]

    iex> BusinessDays.ago(~D[2018-07-05], 1, ~W[USD])
    ~D[2018-07-03]

Negative skips are supported, behaving as the "opposite" method was called:

    iex> BusinessDays.ago(~D[2018-07-03], -1, ~W[USD])
    ~D[2018-07-03]

    iex> BusinessDays.since(~D[2018-07-05], -1, ~W[USD])
    ~D[2018-07-03]

Week-ends are skipped too:

    iex> BusinessDays.since(~D[2018-07-28], 0)
    ~D[2018-07-30]

    iex> BusinessDays.ago(~D[2018-07-28], 0)
    ~D[2018-07-27]


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fx_holidays_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:business_days, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/business_days](https://hexdocs.pm/fx_holidays_ex).

