defmodule Clik.Option do
  defstruct [:default, :help, :hidden, :long, :name, :required, :short, :type]

  @type t :: %__MODULE__{}
  @type option_type :: :float | :integer | :string | :boolean | :count
  @type option_value :: float() | integer() | String.t() | boolean()
  @type opt ::
          {:default, option_value()}
          | {:help, String.t()}
          | {:hidden, boolean()}
          | {:long, atom()}
          | {:required, boolean()}
          | {:short, atom()}
          | {:type, option_type()}
  @type opts :: [] | [opt()]
  @type error :: {:error, atom()}

  @default_default nil
  @default_help ""
  @default_hidden false
  @default_required false
  @default_short nil
  @default_type :string
  @valid_types [:boolean, :count, :float, :integer, :string]

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

  @spec prepare(t()) :: {{atom(), option_type()}, nil | {atom(), atom()}}
  def prepare(option) do
    long_form = {option.long, option.type}

    aliases =
      if option.short != nil do
        {option.short, option.long}
      else
        nil
      end

    {long_form, aliases}
  end

  defp validate(option) do
    cond do
      option.required and option.default != nil ->
        {:error, :badarg}

      option.type not in @valid_types ->
        {:error, :badarg}

      not is_bitstring(option.help) ->
        {:error, :badarg}

      not check_default_value_type(option.default, option.type) ->
        {:error, :badarg}

      not check_short_name(option.short) ->
        {:error, :badarg}

      option.short == option.long ->
        {:error, :badarg}

      true ->
        {:ok, option}
    end
  end

  defp check_short_name(nil), do: true

  defp check_short_name(name) do
    String.length(Atom.to_string(name)) == 1
  end

  defp check_default_value_type(nil, _), do: true
  defp check_default_value_type(default_value, :boolean) when is_boolean(default_value), do: true
  defp check_default_value_type(_default_value, :boolean), do: false
  defp check_default_value_type(default_value, :count) when is_integer(default_value), do: true
  defp check_default_value_type(_default_value, :count), do: false
  defp check_default_value_type(default_value, :float) when is_float(default_value), do: true
  defp check_default_value_type(_default_value, :float), do: false
  defp check_default_value_type(default_value, :integer) when is_integer(default_value), do: true
  defp check_default_value_type(_default_value, :integer), do: false
  defp check_default_value_type(default_value, :string) when is_bitstring(default_value), do: true
  defp check_default_value_type(_default_value, :string), do: false
end
