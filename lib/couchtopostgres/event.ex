defmodule Couchtopostgres.Event do
  use Ecto.Schema

  def mail_dump_id_from_mailgun_id(nil), do: nil

  def mail_dump_id_from_mailgun_id(mailgun_id) do
    Repo.get_by(Event, mailgun_id: mailgun_id).id
  end

  schema "events" do
    field :kind,         :string
    field :signature,    :string
    field :mail_dump_id, :integer
    field :received_at,  Timex.Ecto.DateTime
  end
end
