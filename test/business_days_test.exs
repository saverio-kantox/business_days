defmodule BusinessDaysTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  doctest BusinessDays

  setup_all do
    output =
      capture_log(fn ->
        BusinessDays.start_link(%{
          "USD" => ~W[2018-01-01 2018-07-04 2018-12-25],
          "EUR" => ~W[2018-01-01 2018-08-15 2018-12-25 foo 2018-32-45],
          "AUD" => [~D[2018-01-01]],
          "GBP" => [{2018, 1, 1}]
        })
      end)

    %{output: output}
  end

  test "logs failing inputs", %{output: output} do
    assert output =~ ~R"invalid_format foo"
    assert output =~ ~R"invalid_date 2018-32-45"
  end

  test "merge calendars" do
    assert BusinessDays.holidays(~W[USD EUR]) == [
             ~D[2018-01-01],
             ~D[2018-07-04],
             ~D[2018-08-15],
             ~D[2018-12-25]
           ]
  end

  test "skips weekends" do
    assert BusinessDays.since(~D[2018-07-28], 0) == ~D[2018-07-30]
    assert BusinessDays.since(~D[2018-07-28], 0, ~W[USD EUR]) == ~D[2018-07-30]
    assert BusinessDays.since(~D[2018-07-29], 0) == ~D[2018-07-30]
    assert BusinessDays.since(~D[2018-07-29], 0, ~W[USD EUR]) == ~D[2018-07-30]
  end

  test "skips holidays" do
    assert BusinessDays.since(~D[2018-07-03], 1, ~W[USD]) == ~D[2018-07-05]
    assert BusinessDays.since(~D[2018-07-04], 0, ~W[USD]) == ~D[2018-07-05]
    assert BusinessDays.since(~D[2018-07-05], -1, ~W[USD]) == ~D[2018-07-03]
    assert BusinessDays.since(~D[2018-07-05], 0, ~W[USD]) == ~D[2018-07-05]
  end

  test "roll to same when it is a business day" do
    assert BusinessDays.since(~D[2018-07-30], 0) == ~D[2018-07-30]
  end
end
