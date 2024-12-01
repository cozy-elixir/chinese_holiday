defmodule ChineseHoliday do
  @moduledoc """
  Provides utilities for handling chinese holiday related problems.
  """

  require Logger
  alias __MODULE__.Data

  @supported_years Data.get_supported_years()
  @data_updated_datetime Data.get_updated_datetime()

  @doc """
  Gets all the supported years.

  ## Examples

      iex> ChineseHoliday.get_supported_years()
      [2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025]

  """
  @spec get_supported_years() :: list()
  def get_supported_years(), do: @supported_years

  @doc """
  Gets the version of data.

  The version is a plain `%DateTime{}`.

  ## Examples

      iex> ChineseHoliday.get_version()
      ~U[2024-11-30 12:41:00Z]

  """
  @spec get_version() :: DateTime.t()
  def get_version(), do: @data_updated_datetime

  @doc """
  Checks if a given date is a holiday.

  Following dates will be considered as holidays:

  * dates in holiday schedules which are published by State Council of the People's Republic of China,
    aka. chinese statutory holiday.

  > To get the original information, please visit
  > [中华人民共和国中央人民政府 - 政府信息公开](http://www.gov.cn/zhengce/xxgk/index.htm),
  > and search '节假日'.

  ## Examples

      # the holiday of lunar new year
      iex> ChineseHoliday.holiday?(~D[2023-01-21])
      true

      # the holiday of lunar new year
      iex> ChineseHoliday.holiday?(~D[2023-01-27])
      true

      # it's time to work ;)
      iex> ChineseHoliday.holiday?(~D[2023-01-28])
      false

      # the holiday information is missing, so this function doesn't know how to handle it.
      # in this case, it will log a warning message, and return `false`.
      iex> ChineseHoliday.holiday?(~D[2090-01-28])
      false

  """
  @spec holiday?(Date.t()) :: boolean()
  def holiday?(%Date{year: year} = _date) when year not in @supported_years do
    Logger.warning(fn ->
      "the holiday information of #{year} isn't provided by current version of chinese_holiday"
    end)

    false
  end

  Data.get_holidays()
  |> Enum.map(fn entry ->
    %{entry | date: Macro.escape(entry.date)}
  end)
  |> Enum.each(fn %{date: date} ->
    def holiday?(unquote(date)), do: true
  end)

  def holiday?(_), do: false

  @doc """
  Checks if a given date is a working day.

  Following dates will be considered as working days:

  * dates marked as additional working days to compensate for the long holiday break.
  * dates which are normal weekdays (monday ~ friday), and are not in the duration of any holiday.

  ## Examples

      # additional working days
      iex> ChineseHoliday.working_day?(~D[2023-01-28])
      true

      iex> ChineseHoliday.working_day?(~D[2023-01-29])
      true

      # weekdays in the duration of one holiday
      iex> ChineseHoliday.working_day?(~D[2023-01-27])
      false

      # normal weekdays
      iex> ChineseHoliday.working_day?(~D[2023-01-30])
      true

      iex> ChineseHoliday.working_day?(~D[2023-01-31])
      true

      # normal weekends
      iex> ChineseHoliday.working_day?(~D[2023-02-11])
      false

      # the working day information is missing, so this function doesn't know how to handle it.
      # in this case, it will log a warning message, and return `false`.
      iex> ChineseHoliday.working_day?(~D[2090-01-28])
      false

  """
  @spec working_day?(Date.t()) :: boolean()
  def working_day?(%Date{year: year}) when year not in @supported_years do
    Logger.warning(fn ->
      "the working day information of #{year} isn't provided by current version of chinese_holiday"
    end)

    false
  end

  Data.get_working_days()
  |> Enum.map(fn entry ->
    %{entry | date: Macro.escape(entry.date)}
  end)
  |> Enum.each(fn %{date: date} ->
    def working_day?(unquote(date)), do: true
  end)

  def working_day?(%Date{} = date) do
    %{year: year, month: month, day: day} = date
    weekday = :calendar.day_of_the_week(year, month, day)
    !holiday?(date) and weekday in 1..5
  end
end
