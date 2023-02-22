defmodule Clik.DuplicateOptionError do
  defexception [:message]

  alias Clik.Option

  @impl true
  def exception(opt) do
    name = format_option_name(opt)
    %__MODULE__{message: "Duplicate option #{name}"}
  end

  defp format_option_name(%Option{name: name, long: long, short: nil}) do
    "#{name} (--#{long})"
  end

  defp format_option_name(%Option{name: name, long: long, short: short}) do
    "#{name} (--#{long}, -#{short})"
  end
end

defmodule Clik.DuplicateCommandError do
  defexception [:message]

  @impl true
  def exception(command) do
    %__MODULE__{message: "Duplicate command #{command.name}"}
  end
end

defmodule Clik.UnknownCommandError do
  defexception [:message]

  @impl true
  def exception(name) do
    %__MODULE__{message: "Unknown command #{name}"}
  end
end
