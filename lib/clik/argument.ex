defmodule Clik.Argument do
  defstruct [:name, :type, :required]

  @type t :: %__MODULE__{}
  @type error :: {:error, atom()}
  @type type :: :boolean | :float | :integer | :string
  @type opt :: {:type, type()} | {:required, boolean()}
  @type opts :: [] | [opt()]

  @default_type :string
  @default_required false
  @valid_types [:boolean, :float, :integer, :string]

  @spec new(atom(), opts()) :: {:ok, t()} | error()
  def new(name, opts \\ []) do
    validate(%__MODULE__{
      name: name,
      type: Keyword.get(opts, :type, @default_type),
      required: Keyword.get(opts, :required, @default_required)
    })
  end

  @spec new!(atom(), opts()) :: t() | no_return()
  def new!(name, opts \\ []) do
    case new(name, opts) do
      {:ok, arg} ->
        arg

      {:error, :badarg} ->
        raise ArgumentError
    end
  end

  defp validate(arg) do
    cond do
      arg.type not in @valid_types ->
        {:error, :badarg}

      not is_boolean(arg.required) ->
        {:error, :badarg}

      true ->
        {:ok, arg}
    end
  end
end
