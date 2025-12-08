defmodule Mix.Tasks.GenerateProtos do
  use Mix.Task

  @shortdoc "Generate the proto files"

  @moduledoc """
  A simple example Mix task.

  Usage:
      mix generate_protos
  """

  def run(_args) do
    Mix.shell().info("Generating proto files...")
    # Assuming you have .proto files in the "priv/protos" directory
    proto_files = Path.wildcard("priv/protos/*.proto")

    Enum.each(proto_files, fn file ->
      Mix.shell().info("Compiling #{file}...")

      filename =
        Path.basename(file)
        |> Path.rootname()

      Mix.Task.run("protox.generate", [
        "--output-path=lib/#{filename}.ex",
        "#{file}"
      ])
    end)
  end
end
