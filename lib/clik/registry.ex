defmodule Clik.Registry do
  defstruct global_options: %{}, commands: %{}
  alias Clik.{Command, Option}
  alias Clik.{DuplicateCommandError, DuplicateOptionError, UnknownCommandError}

  @type t :: %__MODULE__{
          global_options: %{atom() => Option.t()},
          commands: %{atom() => Command.t()}
        }

  @spec add_global_option(t(), Option.t()) :: {:ok, t()} | {:error, :duplicate}
  def add_global_option(registry, option) do
    if Map.has_key?(registry.global_options, option.name) do
      {:error, :duplicate}
    else
      {:ok, %{registry | global_options: Map.put(registry.global_options, option.name, option)}}
    end
  end

  @spec add_global_option!(t(), Option.t()) :: t() | no_return()
  def add_global_option!(registry, option) do
    case add_global_option(registry, option) do
      {:error, :duplicate} ->
        raise DuplicateOptionError, option

      {:ok, registry} ->
        registry
    end
  end

  @spec add_command(t(), Command.t()) ::
          {:ok, t()} | {:error, :duplicate_command} | {:error, :duplicate_option, Option.t()}
  def add_command(registry, command) do
    if Map.has_key?(registry.commands, command.name) do
      {:error, :duplicate_command}
    else
      case check_duplicate_options(registry, command) do
        :ok ->
          {:ok, %{registry | commands: Map.put(registry.commands, command.name, command)}}

        {:error, option} ->
          {:error, :duplicate_option, option}
      end
    end
  end

  @spec add_command!(t(), Command.t()) :: t() | no_return()
  def add_command!(registry, command) do
    case add_command(registry, command) do
      {:error, :duplicate_command} ->
        raise DuplicateCommandError, command

      {:error, :duplicate_option, option} ->
        raise DuplicateOptionError, option

      {:ok, registry} ->
        registry
    end
  end

  def command(registry, name) do
    if Map.has_key?(registry.commands, name) do
      {:ok, Map.get(registry.commands, name)}
    else
      {:error, :unknown_command}
    end
  end

  def command!(registry, name) do
    case command(registry, name) do
      {:ok, cmd} ->
        cmd

      {:error, :unknown_command} ->
        raise UnknownCommandError, name
    end
  end

  @spec has_default?(t()) :: boolean()
  def has_default?(registry), do: Map.has_key?(registry.commands, :default)

  @spec has_command?(t(), atom()) :: boolean()
  def has_command?(registry, cmd_name), do: Map.has_key?(registry.commands, cmd_name)

  @spec options(t(), atom()) :: {:ok, %{atom() => Option.t()}} | {:error, :unknown_command}
  def options(registry, command_name) do
    if Map.has_key?(registry.commands, command_name) do
      command = Map.get(registry.commands, command_name)

      {:ok,
       Enum.map(Command.options(command), &{&1.name, &1}) |> Enum.into(registry.global_options)}
    else
      {:error, :unknown_command}
    end
  end

  def options!(registry, command_name) do
    case options(registry, command_name) do
      {:ok, options} ->
        options

      {:error, :unknown_command} ->
        raise UnknownCommandError, command_name
    end
  end

  @spec prepare(t(), atom() | nil) :: {:ok, Keyword.t()} | {:error, :unknown_command}
  def prepare(registry, command_name \\ nil)

  def prepare(registry, nil) do
    {switches, aliases} = prepare_options(registry.global_options)
    {:ok, [strict: switches, aliases: aliases]}
  end

  def prepare(registry, command_name) do
    case options(registry, command_name) do
      {:ok, cmd_opts} ->
        all_opts = Map.merge(registry.global_options, cmd_opts)
        {switches, aliases} = prepare_options(all_opts)
        {:ok, [strict: switches, aliases: aliases]}

      error ->
        error
    end
  end

  defp check_duplicate_options(%__MODULE__{global_options: globals}, command) do
    Enum.reduce_while(Command.options(command), :ok, fn option, _ ->
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
