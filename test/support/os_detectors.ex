defmodule Clik.Test.WindowsNTDetector do
  def type(), do: {:nt, nil}
end

defmodule Clik.Test.Windows32BitDetector do
  def type(), do: {:win32, nil}
end

defmodule Clik.Test.LinuxDetector do
  def type(), do: {:unix, :linux}
end

defmodule Clik.Test.MacDetector do
  def type(), do: {:unix, :darwin}
end
