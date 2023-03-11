defmodule Clik.Output.HelpFormatter do
  alias Clik.Configuration
  alias Clik.Output.Document
  alias Clik.Output.Formatters.{CommandHelp, GlobalHelp, SingleCommandHelp}

  @spec script_help(Configuration.t()) :: Document.t()
  def script_help(config) do
    if Enum.count(config.commands) == 1 do
      SingleCommandHelp.format(config, Document.empty())
    else
      GlobalHelp.format(config, Document.empty())
    end
  end

  @spec command_help!(Configuration.t(), atom()) :: Document.t() | no_return()
  def command_help!(config, command_name) do
    command = Configuration.command!(config, command_name)
    CommandHelp.format(config, command, Document.empty())
  end
end
