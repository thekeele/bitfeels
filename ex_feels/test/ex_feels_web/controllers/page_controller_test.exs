defmodule ExFeelsWeb.PageControllerTest do
  use ExFeelsWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to ExFeels"
  end
end
