defmodule Clik.Option do
  @opaque t :: %__MODULE__{}
  @type error :: {:error, atom()}
  @type options :: [t] | []
  @type option_type :: :float | :integer | :string | :boolean | :count
  @type option_value :: float() | integer() | String.t() | boolean()
  @type opt ::
          {:type, option_type()}
          | {:required, boolean()}
          | {:default, option_value()}
          | {:required, boolean()}
          | {:hidden, boolean()}
          | {:help, String.t()}
          | {:long, atom()}
          | {:short, atom()}
  @type opts :: [opt()]

  @default_default nil
  @default_help ""
  @default_hidden false
  @default_required false
  @default_short nil
  @default_type :string

  @valid_types [:boolean, :count, :float, :integer, :string]

  defstruct [:default, :help, :hidden, :long, :name, :required, :short, :type]

  @spec new(atom(), opts()) :: {:ok, t()} | error()
  def new(name, opts \\ []) do
    validate(%__MODULE__{
      name: name,
      default: Keyword.get(opts, :default, @default_default),
      help: Keyword.get(opts, :help, @default_help),
      hidden: Keyword.get(opts, :hidden, @default_hidden),
      long: Keyword.get(opts, :long, name),
      required: Keyword.get(opts, :required, @default_required),
      short: Keyword.get(opts, :short, @default_short),
      type: Keyword.get(opts, :type, @default_type)
    })
  end

  @spec new!(atom(), opts()) :: t() | no_return()
  def new!(name, opts \\ []) do
    case new(name, opts) do
      {:ok, option} ->
        option

      {:error, :badarg} ->
        raise ArgumentError
    end
  end

  @spec prepare(t()) :: {{atom(), atom()}, {atom(), atom()} | nil}
  def prepare(option) do
    flag = {option.long, option.type}

    if option.short == nil do
      {flag, nil}
    else
      {flag, {option.short, option.long}}
    end
  end

  @spec help(t()) :: String.t()
  def help(opt), do: opt.help

  defp validate(option) do
    cond do
      option.required and option.default != nil ->
        {:error, :badarg}

      option.type not in @valid_types ->
        {:error, :badarg}

      true ->
        {:ok, option}
    end
  end
end

defmodule Clik.Options do
  alias Clik.Option

  @type option_values :: [term()] | []
  @type arguments :: [String.t()] | []
  @type reason :: {:missing_option, atom()}

  @spec parse([String.t()], Option.options()) ::
          {:ok, {option_values(), arguments()}} | {:error, reason()}
  def parse(argv, options) do
    {flags, aliases} =
      Enum.reduce(options, {[], []}, fn option, {flags, aliases} ->
        {flag, flag_alias} = Option.prepare(option)

        aliases =
          if flag_alias == nil do
            aliases
          else
            [flag_alias | aliases]
          end

        {[flag | flags], aliases}
      end)

    {parsed, arguments, _} = OptionParser.parse(argv, strict: flags, aliases: aliases)

    case assign_parsed_results(parsed, options) do
      {:error, _} = error ->
        error

      assigned ->
        {:ok, {assigned, arguments}}
    end
  end

  defp assign_parsed_results(parsed, options) do
    Enum.reduce_while(options, [], fn opt, acc ->
      value = Keyword.get(parsed, opt.long, opt.default)

      cond do
        value == nil and opt.required ->
          {:halt, {:error, {:missing_option, opt.long}}}

        value == nil and opt.type == :boolean ->
          {:cont, [{opt.long, false} | acc]}

        true ->
          {:cont, [{opt.long, value} | acc]}
      end
    end)
  end
end
