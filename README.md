## What is Clik?

Clik is a library designed to simplify writing CLI apps in Elixir. Clik handles important but tedious tasks like handling CLI options
and generating useful help output.

A complete Mix project which demonstrates how to build a CLI app with Clik is available [here](http://github.com/kevsmith/hello_clik).

## Brief example

```Elixir
defmodule HelloClik do
  use Clik.Command
  alias Clik.{Command, CommandEnvironment, Configuration, Option, Platform}
  alias Clik.Renderable
  alias Clik.Output.Table

  def help_text(), do: "Say hello to the world"

  def options() do
    %{
      verbose: Option.new!(:verbose, short: :v, type: :boolean, help: "Be verbose"),
      table: Option.new!(:table, short: :t, type: :boolean, help: "Use a table")
    }
  end

  def run(env) do
    use_tables = Keyword.get(env.options, :table, false)

    greeting =
      if Keyword.get(env.options, :verbose, false) == true do
        "Greetings and salutations!"
      else
        "Hello!"
      end

    write_output(use_tables, greeting, env.output)
  end

  defp write_output(false, greeting, out) do
    IO.puts(out, greeting)
  end

  defp write_output(true, greeting, out) do
    t =
      Table.empty(2, ["Type", "Phrase"])
      |> Table.add_row(["Greeting", greeting])

    Renderable.render(t, out)
  end

  def main(args) do
    config =
      Configuration.add_command!(
        Configuration.new(),
        Command.new!(:hello, __MODULE__)
      )

    env = CommandEnvironment.new(Platform.script_name())
    Clik.run(config, args, env)
  end
end
```
## Testing

```
Percentage | Module
-----------|--------------------------
    66.67% | Clik.CommandEnvironment
    73.68% | Clik.Platform
    74.51% | Clik
    80.00% | Clik.Command
    80.00% | Clik.Renderable.Clik.Output.Document
    84.85% | Clik.Output.Formatters.Options
    85.71% | Clik.Output.Formatters.CommandHelp
    90.00% | Clik.Output.Formatters.SingleCommandHelp
    90.91% | Clik.Output.Document
    90.91% | Clik.Output.Text
    93.75% | Clik.Option
    94.74% | Clik.Output.Table
    96.49% | Clik.Configuration
   100.00% | Clik.DuplicateCommandNameError
   100.00% | Clik.Output.Formatters.GlobalHelp
   100.00% | Clik.Output.HelpFormatter
   100.00% | Clik.Renderable.Clik.Output.Table
   100.00% | Clik.Renderable.Clik.Output.Text
   100.00% | Clik.Test.LinuxDetector
   100.00% | Clik.Test.MacDetector
   100.00% | Clik.Test.Windows32BitDetector
   100.00% | Clik.Test.WindowsNTDetector
   100.00% | Clik.UnknownCommandNameError
   100.00% | String.Chars.Clik.Output.Text
-----------|--------------------------
    89.28% | Total
```