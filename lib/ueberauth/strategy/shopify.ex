defmodule Ueberauth.Strategy.Shopify do
  @moduledoc """
  Provides an Ueberauth strategy for authenticating with Shopify.

  ### Setup

  Create an application an embedded application in Shopify that your users will authenticate for use.

  Register a new application at: [your github developer page](https://github.com/settings/developers) and get the `client_id` and `client_secret`.

  Include the provider in your configuration for Ueberauth

      config :ueberauth, Ueberauth,
        providers: [
          shopify: { Ueberauth.Strategy.Shopify, [] }
        ]

  Then include the configuration for shopify.

      config :ueberauth, Ueberauth.Strategy.Shopify.OAuth,
        client_id: System.get_env("SHOPIFY_API_KEY"),
        client_secret: System.get_env("SHOPIFY_SECRET")

  If you haven't already, create a pipeline and setup routes for your callback handler

      pipeline :auth do
        Ueberauth.plug "/auth"
      end

      scope "/auth" do
        pipe_through [:browser, :auth]

        get "/:provider/callback", AuthController, :callback
      end


  Create an endpoint for the callback where you will handle the `Ueberauth.Auth` struct

      defmodule MyApp.AuthController do
        use MyApp.Web, :controller

        def callback_phase(%{ assigns: %{ ueberauth_failure: fails } } = conn, _params) do
          # do things with the failure
        end

        def callback_phase(%{ assigns: %{ ueberauth_auth: auth } } = conn, params) do
          # do things with the auth
        end
      end

  You can edit the behaviour of the Strategy by including some options when you register your provider.

  To set the `uid_field`

      config :ueberauth, Ueberauth,
        providers: [
          shopify: { Ueberauth.Strategy.Shopify, [uid_field: :shop] }
        ]

  Default is `:login`

  To set the default 'scopes' (permissions):

      config :ueberauth, Ueberauth,
        providers: [
          shopify: { Ueberauth.Strategy.Shopify, [default_scope: "read_products,read_customers,read_orders"] }
        ]

  Deafult is "read_products,read_customers,read_orders"
  """
  use Ueberauth.Strategy, uid_field: :shop, default_scope: "read_products,read_customers,read_orders"

  alias Ueberauth.Auth.Credentials

  @doc """
  Handles the initial redirect to the Shopify authentication page.

  To customize the scope (permissions) that are requested by shopify include them as part of your url:

      "https://{shop}.myshopify.com/admin/oauth/authorize?scope=read_products,read_customers,read_orders"

  You can also include a `state` param that shopify will return to you.
  """
  def handle_request!(%Plug.Conn{ params: %{ "shop" => shop } } = conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)
    opts = [ site: "https://" <> shop ]
    params = [ scope: scopes ]
    params = if conn.params["state"], do: Keyword.put(params, :state, conn.params["state"]), else: params
    params = Keyword.put(params, :redirect_uri, callback_url(conn))

    redirect!(conn, Ueberauth.Strategy.Shopify.OAuth.authorize_url!(params, opts))
  end

  @doc """
  Handles the callback from Shopify. When there is a failure from Shopify the failure is included in the
  `ueberauth_failure` struct. Otherwise the information returned from Shopify is returned in the `Ueberauth.Auth` struct.
  """
  def handle_callback!(%Plug.Conn{ params: %{ "code" => code, "shop" => shop } } = conn) do
    opts = [redirect_uri: callback_url(conn), site: "https://" <> shop]
    %{token: token} = Ueberauth.Strategy.Shopify.OAuth.get_token!([
      code: code,
      client_secret: Ueberauth.Strategy.Shopify.OAuth.new_client().client_secret
    ], opts)
    if token.access_token == nil do
      set_errors!(conn, [error(token.other_params["error"], token.other_params["error_description"])])
    else
      put_private(conn, :shopify_token, token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code or shop received")])
  end

  @doc """
  Cleans up the private area of the connection used for passing the raw Shopify response around during the callback.
  """
  def handle_cleanup!(conn) do
    conn
    |> put_private(:shopify_user, nil)
    |> put_private(:shopify_token, nil)
  end

  @doc """
  Fetches the uid field from the Shopify response. This defaults to the option `uid_field` which in-turn defaults to `login`
  """
  def uid(%Plug.Conn{ params: %{ "shop" => shop } }) do
    shop
  end

  @doc """
  Includes the credentials from the Shopify response.
  """
  def credentials(conn) do
    token = conn.private.shopify_token
    scopes = (token.other_params["scope"] || "")
    |> String.split(",")

    %Credentials{
      token: token.access_token,
      refresh_token: token.refresh_token,
      expires_at: token.expires_at,
      token_type: token.token_type,
      expires: !!token.expires_at,
      scopes: scopes
    }
  end
  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end
end
