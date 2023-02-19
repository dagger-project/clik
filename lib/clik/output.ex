defmodule Clik.Output do
  @type dest :: :file.fd() | IO.device()
  @type reason :: :file.posix() | :badarg | :terminated

  @spec puts(dest(), iodata()) :: :ok | {:error, reason()}
  def puts({:file_descriptor, _, _} = fd, data) do
    :file.write(fd, data)
  end

  def puts(:stdout, data), do: IO.puts(data)

  def puts(device, data) do
    IO.puts(device, data)
  end
end
