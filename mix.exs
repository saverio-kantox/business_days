defmodule BusinessDays.MixProject do
  use Mix.Project

  @app :business_days
  @version "0.1.0"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      name: "#{@app}",
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp docs() do
    [
      main: "README",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/#{@app}",
      logo: "public/icon.png",
      source_url: "https://github.com/saverio-kantox/#{@app}",
      extras: [
        "README.md"
      ],
      groups_for_modules: []
    ]
  end
end
