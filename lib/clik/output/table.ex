defmodule Clik.Output.Table do
  defstruct columns: nil, headers: nil, rows: [], max_widths: %{}

  def empty(columns \\ 2, headers \\ []) do
    %__MODULE__{columns: columns, headers: headers}
  end

  def add_row(table, columns) do
    if length(columns) > table.columns do
      {:error, :badarg}
    else
      padded = maybe_pad_columns(table, columns)
      %{table | rows: [padded | table.rows], max_widths: update_widths(table.max_widths, padded)}
    end
  end

  def empty?(table) do
    size(table) == 0
  end

  def size(table) do
    Enum.count(table.rows)
  end

  defp maybe_pad_columns(table, columns) do
    case table.columns - length(columns) do
      0 ->
        columns

      n ->
        padding = Enum.map(1..n, fn _ -> "" end)
        columns ++ padding
    end
  end

  defp update_widths(widths, columns) when map_size(widths) == 0 do
    Enum.with_index(columns)
    |> Enum.reduce(%{}, fn {col, index}, acc -> Map.put(acc, index, String.length(col)) end)
  end

  defp update_widths(widths, columns) do
    Enum.with_index(columns)
    |> Enum.reduce(%{}, fn {col, index}, acc ->
      col_width = String.length(col)
      existing_width = Map.get(widths, index, 0)

      if col_width > existing_width do
        Map.put(acc, index, col_width)
      else
        Map.put(acc, index, existing_width)
      end
    end)
  end
end

defimpl Clik.Renderable, for: Clik.Output.Table do
  require Integer
  alias Clik.Platform
  alias Clik.Output.Table

  @ellipses "..."

  def render(table, out) do
    max_col_width = trunc(Platform.terminal_width() / table.columns) - 1
    table = calculate_final_col_widths(table, max_col_width)

    text = [
      render_headers(table),
      render_rows(table),
      Platform.eol_char()
    ]

    {IO.write(out, text), out}
  end

  defp calculate_final_col_widths(table, max_col_width) do
    updated =
      Enum.reduce(table.max_widths, %{}, fn
        {key, width}, acc when width > max_col_width ->
          Map.put(acc, key, max_col_width)

        {key, width}, acc ->
          padding = min(5, max_col_width - width)
          Map.put(acc, key, width + padding)
      end)

    %{table | max_widths: updated}
  end

  defp render_headers(%Table{headers: []}), do: ""

  defp render_headers(table) do
    (Enum.with_index(table.headers)
     |> Enum.map(fn {header, index} ->
       format_header(header, Map.get(table.max_widths, index))
     end)) ++ [Platform.eol_char()]
  end

  defp render_rows(table) do
    Enum.reverse(table.rows)
    |> Enum.map(fn row -> render_row(row, table) end)
    |> Enum.join(Platform.eol_char())
  end

  defp render_row(row, table) do
    Enum.with_index(row)
    |> Enum.map(fn {col, index} ->
      format_column(col, Map.get(table.max_widths, index))
    end)
    |> Enum.join()
  end

  defp format_header(header, col_width) when is_binary(header) do
    format_header({:left, header}, col_width)
  end

  defp format_header({position, header}, col_width) do
    header = maybe_truncate_col(header, col_width)
    position_text(position, header, col_width + 1)
  end

  defp format_column(col, col_width) when is_binary(col) do
    format_column({:left, col}, col_width)
  end

  defp format_column({position, col}, col_width) do
    col = maybe_truncate_col(col, col_width)
    position_text(position, col, col_width + 1)
  end

  defp maybe_truncate_col(col, col_width) do
    if String.length(col) > col_width do
      if col_width <= 4 do
        @ellipses
      else
        String.slice(col, 0..(col_width - 4)) <> @ellipses
      end
    else
      col
    end
  end

  defp position_text(:left, text, width) do
    String.pad_trailing(text, width)
  end

  defp position_text(:right, text, width) do
    String.pad_leading(text, width)
  end

  defp position_text(:center, text, width) do
    text_width = String.length(text)
    precise_padding = (width - text_width) / 2
    base_padding = trunc(precise_padding)

    {leading, trailing} =
      if precise_padding - base_padding > 0 do
        {base_padding, base_padding + 1}
      else
        {base_padding, base_padding}
      end

    String.duplicate(" ", leading) <> text <> String.duplicate(" ", trailing)
  end
end
