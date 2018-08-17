defmodule Couchtopostgres.MailDump do
  use Ecto.Schema
  import Ecto.Query
  
  def insert(item) do
    Couchtopostgres.Repo.insert item
  end

  def delivery_id_from_symbolic_name(symbolic_name) do
    Couchtopostgres.Repo.get_by(Couchtopostgres.Delivery, symbolic_name: symbolic_name).id
  end

  def mail_dump_exists?(nil, id), do: true

  def mail_dump_exists?(uuid, _) do
    case Couchtopostgres.Repo.all(from(w in Couchtopostgres.MailDump) |> where([w], w.uuid == ^uuid) |> limit(1)) do
      [] -> false
      _  -> true
    end
  end

  schema "mail_dumps" do
    field :delivery_id, :integer
    field :site_key,    :string
    field :from,        :string
    field :to,          :string
    field :cc,          { :array, :string }
    field :bcc,         { :array, :string }
    field :subject,     :string
    field :mailgun_id,  :string
    field :body,        :string
    field :metadata,    :map
    field :sent_at,     Timex.Ecto.DateTime
    field :uuid,        :string
    field :created_at,  Timex.Ecto.DateTime
    field :updated_at,  Timex.Ecto.DateTime
  end
end
