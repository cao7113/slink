defmodule EnvHelper do
  def enabled?(env_var) do
    System.get_env(env_var, "false")
    |> String.downcase()
    |> Kernel.==("true")
  end
end
