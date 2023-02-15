defmodule Clik do
  alias Clik.Command

  @type commands :: %{atom() => Command.t()}

  @spec run([String.t()], commands()) :: :ok | :error
  def run(argv, commands) do
    case find_command(argv, commands) do
      {:ok, {args, command}} ->
        Command.run(command, args)

      {:error, :unknown_command} ->
        IO.puts(:stderr, "Unknown command")
        :error
    end
  end

  defp find_command([], commands) do
    {:ok, {[], Map.fetch!(commands, :default)}}
  end

  defp find_command([arg | rest], commands) do
    try do
      name = String.to_existing_atom(arg)

      if Map.has_key?(commands, name) do
        {:ok, {rest, Map.fetch!(commands, name)}}
      else
        {:error, :unknown_command}
      end
    rescue
      ArgumentError ->
        {:error, :unknown_command}
    end
  end
end
