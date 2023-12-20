defmodule ChineseHoliday.Data do
  @moduledoc false

  def get_supported_years() do
    get_data()
    |> Enum.map(& &1.year)
    |> Enum.reverse()
  end

  def get_updated_datetime() do
    get_data()
    |> List.first()
    |> Map.fetch!(:updated_at)
  end

  def get_holidays() do
    get_data()
    |> Enum.map(& &1.detail)
    |> Enum.concat()
    |> Enum.filter(&(&1.type == :holiday))
    |> Enum.map(fn
      %{name: name, range: %Date.Range{} = date_range} ->
        Enum.map(date_range, &%{name: name, date: &1})

      %{name: name, range: %Date{} = date} ->
        %{name: name, date: date}
    end)
    |> List.flatten()
  end

  def get_working_days() do
    get_data()
    |> Enum.map(& &1.detail)
    |> Enum.concat()
    |> Enum.filter(&(&1.type == :working_day))
    |> Enum.map(fn
      %{name: name, range: %Date.Range{} = date_range} ->
        Enum.map(date_range, &%{name: name, date: &1})

      %{name: name, range: %Date{} = date} ->
        %{name: name, date: date}
    end)
    |> List.flatten()
  end

  defp get_data() do
    get_data_dir()
    |> Path.join("index.json")
    |> File.read!()
    |> Jason.decode!(keys: :atoms!)
    |> Enum.map(fn %{year: year, last_modified: last_modified} ->
      updated_at =
        last_modified
        |> NaiveDateTime.from_iso8601!()
        |> DateTime.from_naive!("Asia/Shanghai", Tz.TimeZoneDatabase)
        |> DateTime.shift_zone!("Etc/UTC", Tz.TimeZoneDatabase)

      %{
        year: year,
        updated_at: updated_at,
        detail: get_year_detail(year)
      }
    end)
  end

  defp get_year_detail(year) do
    get_data_dir()
    |> Path.join("#{year}.json")
    |> File.read!()
    |> Jason.decode!(keys: :atoms!)
    |> Enum.map(fn entry ->
      %{
        entry
        | range: transform_range!(entry.range),
          type: transform_type!(entry.type)
      }
    end)
  end

  defp get_data_dir() do
    Path.join(:code.priv_dir(:chinese_holiday), "data")
  end

  defp transform_range!([from, to]) do
    from = Date.from_iso8601!(from)
    to = Date.from_iso8601!(to)
    Date.range(from, to, 1)
  end

  defp transform_range!([day]) do
    Date.from_iso8601!(day)
  end

  defp transform_type!("holiday"), do: :holiday
  defp transform_type!("workingday"), do: :working_day
end
