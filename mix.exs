defmodule BusinessDays.MixProject do
  use Mix.Project

  @app :business_days
  @version "0.1.1"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      name: "#{@app}",
      description: "Business days intervals calculations",
      package: package()
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
      main: "readme",
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

  defp package() do
    [
      licenses: ["MIT"],
      maintainers: ["Saverio Trioni"],
      links: %{
        "GitHub" => "https://github.com/saverio-kantox/#{@app}",
        "Docs" => "https://hexdocs.pm/#{@app}"
      }
    ]
  end
end
