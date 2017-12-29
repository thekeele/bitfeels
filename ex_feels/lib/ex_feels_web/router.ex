defmodule ExFeelsWeb.Router do
  use ExFeelsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/bitfeels", ExFeelsWeb do
    pipe_through :browser # Use the default browser stack

    get "/", HomeController, :home
  end

  # Other scopes may use custom stacks.
  scope "/bitfeels/api", ExFeelsWeb do
    pipe_through :api

    get "/tweets", TweetsController, :index
  end
end
