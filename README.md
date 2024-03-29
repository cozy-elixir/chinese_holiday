# ChineseHoliday

[![CI](https://github.com/cozy-elixir/chinese_holiday/actions/workflows/ci.yml/badge.svg)](https://github.com/cozy-elixir/chinese_holiday/actions/workflows/ci.yml) [![Hex.pm](https://img.shields.io/hexpm/v/chinese_holiday.svg)](https://hex.pm/packages/chinese_holiday)
[![built with Nix](https://img.shields.io/badge/built%20with%20Nix-5277C3?logo=nixos&logoColor=white)](https://builtwithnix.org)

> Provides utilities for handling chinese holiday related problems.

## Installation

Add `:chinese_holiday` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chinese_holiday, "~> <version>"}
  ]
end
```

## Usage

For more information, see the [documentation](https://hexdocs.pm/chinese_holiday/ChineseHoliday.html).

## Development

### Updating data

```console
$ nix develop
$ sync-data
```

## Acknowledgments

The raw data comes from [`bastengao/chinese-holidays-data`](https://github.com/bastengao/chinese-holidays-data).

## License

Apache License 2.0
