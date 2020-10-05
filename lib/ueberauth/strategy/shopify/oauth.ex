defmodule Ueberauth.Strategy.Shopify.OAuth do
  @moduledoc """
  An implementation of OAuth2 for Shopify.

  To add your `client_id` and `client_secret` include these values in your configuration.

      config :ueberauth, Ueberauth.Strategy.Shopify.OAuth,
        client_id: System.get_env("SHOPIFY_API_KEY"),
        client_secret: System.get_env("SHOPIFY_SECRET")

  The `{shop}` value for all OAuth interaction with Shopify will be set dynamically following initial instigation of the OAuth key exchange.
  """
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://{shop}.myshopify.com",
    authorize_url: "/admin/oauth/authorize",
    token_url: "/admin/oauth/access_token",
    redirect_uri: "http://myapp.com/auth/shopify/callback",
  ]

  @doc """
  Construct a client for requests to Shopify using configuration from Application.get_env/2

      Ueberauth.Strategy.Shopify.OAuth.client(redirect_uri: "http://localhost:4000/auth/shopify/callback")

  This will be setup automatically for you in `Ueberauth.Strategy.Shopify`.
  """
  def new_client(opts \\ []) do
    configs = Application.get_env(:ueberauth, Ueberauth.Strategy.Shopify.OAuth)

    opts =
      @defaults
      |> Keyword.merge(configs)
      |> Keyword.merge(opts)

    OAuth2.Client.new(opts)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth. No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> new_client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
    |> new_client
    |> OAuth2.Client.get_token!(params)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
