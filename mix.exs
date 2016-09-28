defmodule UeberauthShopify.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/alistairstead/ueberauth_shopify"


  def project do
    [app: :ueberauth_shopify,
     version: @version,
     elixir: "~> 1.3",
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: @url,
     homepage_url: @url,
     description: description,
     deps: deps,
     docs: docs]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :ueberauth, :oauth2]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:oauth2, "~> 0.7.0"},
     {:ueberauth, "~> 0.3.0"},
     {:earmark, "~> 1.0", only: :dev},
     {:ex_doc, "~> 0.13.0", only: :dev}]
  end

  defp docs do
    [extras: docs_extras]
  end

  defp docs_extras do
    ["README.md"]
  end

  defp description do
    """
      An Ueberauth strategy for authenticating your application with Shopify.
    """
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Alistair Stead"],
      licenses: ["MIT"],
      links: %{"GitHub": @url}]
  end
end
