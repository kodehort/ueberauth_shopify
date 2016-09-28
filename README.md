# Überauth Shopify

> Shopify OAuth2 strategy for Überauth.

## Installation

1. Setup your application at [Shopify](https://app.shopify.com/services/partners/api_clients).

1. Add `:ueberauth_shopify` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_shopify, "~> 0.1"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_shopify]]
    end
    ```

1. Add Google to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        shopify: {Ueberauth.Strategy.Shopify, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Shopify.OAuth,
      client_id: System.get_env("SHOPIFY_API_KEY"),
      client_secret: System.get_env("SHOPIFY_SECRET")
    ```

1.  If you haven't already, create a pipeline and setup routes for your callback handler:

    ```elixir
    pipeline :auth do
      Ueberauth.plug "/auth"
    end

    scope "/auth" do
      pipe_through [:browser, :auth]

      get "/:provider/callback", AuthController, :callback
    end
    ```

1.  Create an endpoint for the callback where you will handle the `Ueberauth.Auth` struct:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller

      def callback_phase(%{ assigns: %{ ueberauth_failure: fails } } = conn, _params) do
        # do things with the failure
      end

      def callback_phase(%{ assigns: %{ ueberauth_auth: auth } } = conn, params) do
        # do things with the auth
      end
    end
    ```

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initial the request through:

    /auth/shopify

Or with options:

    /auth/shopify?scope=read_orders%20read_products

By default the requested scope is "read_products,read_customers,read_orders". Scope can be configured either explicitly as a `scope` query value on the request path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    shopify: { Ueberauth.Strategy.Shopify, [default_scope: "read_products,read_customers,read_orders"] }
  ]
```

## License

Please see [LICENSE](https://github.com/alistairstead/ueberauth_shopify/blob/master/LICENSE) for licensing details.

