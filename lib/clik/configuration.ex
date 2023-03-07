defmodule Clik.Configuration do
  @moduledoc """
  Collects commands and global options.
  """
  defstruct global_options: %{}, commands: %{}, script_help: nil, has_default: false
  alias Clik.{Command, Option}
  alias Clik.{DuplicateCommandError, DuplicateOptionError, UnknownCommandError}

  @typedoc "Global CLI app configuration"
  @type t :: %__MODULE__{
          global_options: %{atom() => Option.t()},
          commands: %{atom() => Command.t()},
          has_default: boolean()
        }

  @doc "Creates a new `Clik.Configuration` instance"
  @doc since: "0.1.0"
  @spec new() :: t()
  def new(script_help \\ nil) do
    help = Option.new!(:help, type: :boolean, short: :h, help: "display this help text")
    add_global_option!(%__MODULE__{script_help: script_help}, help)
  end

  @doc """
  Add a global option to the application configuration.

  Returns {:error, :duplicate} on error.
  """
  @doc since: "0.1.0"
  @spec add_global_option(t(), Option.t()) :: {:ok, t()} | {:error, :duplicate}
  def add_global_option(config, option) do
    if Map.has_key?(config.global_options, option.name) do
      {:error, :duplicate}
    else
      {:ok, %{config | global_options: Map.put(config.global_options, option.name, option)}}
    end
  end

  @doc """
  Add a global option to the application configuration.

  Raises `Clik.DuplicateOptionError` on error.
  """
  @doc since: "0.1.0"
  @spec add_global_option!(t(), Option.t()) :: t() | no_return()
  def add_global_option!(config, option) do
    case add_global_option(config, option) do
      {:error, :duplicate} ->
        raise DuplicateOptionError, option

      {:ok, config} ->
        config
    end
  end

  @doc """
  Add a command to the application configuration.

  Returns `{:error, :duplicate_command}` or `{:error, :duplication_option, option}` on error.
  """
  @doc since: "0.1.0"
  @spec add_command(t(), Command.t()) ::
          {:ok, t()} | {:error, :duplicate_command} | {:error, :duplicate_option, Option.t()}
  def add_command(config, command) do
    if Map.has_key?(config.commands, command.name) do
      {:error, :duplicate_command}
    else
      case check_duplicate_options(config, command) do
        :ok ->
          {:ok, %{config | commands: Map.put(config.commands, command.name, command)}}

        {:error, option} ->
          {:error, :duplicate_option, option}
      end
    end
  end

  @doc """
  Add a command to the application configuration.

  Raises `Clik.DuplicateCommandError` or `Clik.DuplicateOptionError` on error.
  """
  @doc since: "0.1.0"
  @spec add_command!(t(), Command.t()) :: t() | no_return()
  def add_command!(config, command) do
    case add_command(config, command) do
      {:error, :duplicate_command} ->
        raise DuplicateCommandError, command

      {:error, :duplicate_option, option} ->
        raise DuplicateOptionError, option

      {:ok, config} ->
        config
    end
  end

  @doc """
  Look up `Clik.Command` by name.

  Returns {:error, :unknown_command} if `name` is not found.
  """
  @doc since: "0.1.0"
  @spec command(t(), atom()) :: {:ok, Clik.Command.t()} | {:error, :unknown_command}
  def command(config, name) do
    if Map.has_key?(config.commands, name) do
      {:ok, Map.fetch!(config.commands, name)}
    else
      {:error, :unknown_command}
    end
  end

  @doc """
  Look up `Clik.Command` by name.

  Raises `Clik.UnknownCommandError` if `name` is not found.
  """
  @doc since: "0.1.0"
  @spec command!(t(), atom()) :: Command.t() | no_return()
  def command!(config, name) do
    case command(config, name) do
      {:ok, cmd} ->
        cmd

      {:error, :unknown_command} ->
        raise UnknownCommandError, name
    end
  end

  @doc """
  Does the configuration contain a named command?
  """
  @doc since: "0.1.0"
  @spec has_command?(t(), atom()) :: boolean()
  def has_command?(config, name), do: Map.has_key?(config.commands, name)

  @doc """
  Fetch complete set of options for a given named command.

  The complete set of options includes options specific to the command **and** global options.

  Returns `{:error, :unknown_command}` when command name is not found.
  """
  @doc since: "0.1.0"
  @spec options(t(), atom()) :: {:ok, %{atom() => Option.t()}} | {:error, :unknown_command}
  def options(config, command_name \\ nil) do
    result =
      if Enum.count(config.commands) == 1 and command_name == nil do
        [c] = Map.values(config.commands)
        {:ok, c}
      else
        if Map.has_key?(config.commands, command_name) do
          {:ok, Map.get(config.commands, command_name)}
        else
          {:error, :unknown_command}
        end
      end

    case result do
      {:ok, command} ->
        {:ok, Map.merge(Command.options(command), config.global_options)}

      error ->
        error
    end
  end

  @doc """
  Fetch complete set of options for a given named command.

  See `Clik.Configuration.options/2` for more information.

  Raises `Clik.UnknownCommandError` when command not found.
  """
  @doc since: "0.1.0"
  @spec options!(t(), atom()) :: %{atom() => Option.t()} | no_return()
  def options!(config, command_name \\ nil) do
    case options(config, command_name) do
      {:ok, options} ->
        options

      {:error, :unknown_command} ->
        raise UnknownCommandError, command_name
    end
  end

  @doc false
  @spec prepare(t(), atom() | nil) :: {:ok, Keyword.t()} | {:error, :unknown_command}
  def prepare(config, command_name \\ nil)

  def prepare(config, nil) do
    options =
      if Enum.count(config.commands) == 1 do
        [command] = Map.values(config.commands)
        Map.merge(config.global_options, Command.options(command))
      else
        config.global_options
      end

    {switches, aliases} = prepare_options(options)
    {:ok, [strict: switches, aliases: aliases]}
  end

  def prepare(config, command_name) do
    case options(config, command_name) do
      {:ok, cmd_opts} ->
        all_opts = Map.merge(config.global_options, cmd_opts)
        {switches, aliases} = prepare_options(all_opts)
        {:ok, [strict: switches, aliases: aliases]}

      error ->
        error
    end
  end

  defp check_duplicate_options(%__MODULE__{global_options: globals}, command) do
    Enum.reduce_while(Command.options(command), :ok, fn {_, option}, _ ->
      if Map.has_key?(globals, option.name) do
        {:halt, {:error, option}}
      else
        {:cont, :ok}
      end
    end)
  end

  defp prepare_options(opts) do
    Enum.reduce(opts, {[], []}, fn {_, opt}, {switches, aliases} ->
      {opt_switch, opt_alias} = Option.prepare(opt)
      switches = [opt_switch | switches]

      aliases =
        if opt_alias != nil do
          [opt_alias | aliases]
        else
          aliases
        end

      {switches, aliases}
    end)
  end
end
