defmodule Couchtopostgres.Delivery do
  use Ecto.Schema

  schema "deliveries" do
    field :symbolic_name,:string
  end
end
