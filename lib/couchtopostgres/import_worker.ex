defmodule Couchtopostgres.ImportWorker do
  require Logger
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def run, do: GenServer.call(__MODULE__, :run)
  def handle_call(:run, _from, state) do
    spawn_link fn ->
      { :ok, datetime } = Timex.DateTime.now |> Timex.format("{ISO:Extended}")
      IO.puts "IMPORT STARTED at #{datetime}"
      
      Couchtopostgres.ImportWorker.start_import(self())

      receive do
        :finish -> Application.stop(:couchtopostgres)
      end
    end

    {:reply, "run", state}
  end

  def start_import(pid) do
    spawn fn -> fetch_with_limit_and_skip(1000, 0) end
  end

  defp fetch_with_limit_and_skip(pid, _, 5535422) do
    send(pid, :finish)
  end

  defp fetch_with_limit_and_skip(limit, skip) do
    fetch_list("http://admin:admin@localhost:5984/lb_mailer/_all_docs?limit=#{limit}&skip=#{skip}")
    spawn fn -> fetch_with_limit_and_skip(limit, skip + limit) end
  end

  defp fetch_list(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        process_items(Poison.Parser.parse!(body))
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error "#{url} not found"
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error "#{reason} error with #{url}"
    end
  end

  defp fetch_attachment(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      _ ->
        ""
    end
  end

  defp process_items(items_list) do
    Enum.each(items_list["rows"], fn (item) -> spawn fn -> process_item(item["id"]) end end )
  end

  defp process_item(item) do
    fetch_item item
  end

  defp to_datetime(nil) do
  end

  defp to_datetime(string) do
    {:ok, datetime} = Timex.parse(string, "{ISO:Extended}")

    datetime
  end

  defp fetch_item(id) do
    case HTTPoison.get("http://admin:admin@localhost:5984/lb_mailer/#{id}") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        mail_dump = Poison.decode!(body)
        
        case mail_dump["type"] do
          "MailDump" ->
            case Couchtopostgres.MailDump.mail_dump_exists?(mail_dump["uuid"], id) do
              false ->

                body = fetch_attachment("http://admin:admin@localhost:5984/lb_mailer/fff85dee93e5909c80087ebc15edaeef/body.html")
                
                mail_dump_changeset = %Couchtopostgres.MailDump{
                  delivery_id: Couchtopostgres.MailDump.delivery_id_from_symbolic_name(mail_dump["symbolic_name"]),
                  site_key: mail_dump["lang"],
                  from: mail_dump["from"],
                  to: List.first(mail_dump["recipients"]),
                  cc: mail_dump["cc"],
                  bcc: mail_dump["bcc"],
                  subject: mail_dump["subject"],
                  mailgun_id: mail_dump["mailgun_id"],
                  metadata: mail_dump["data"],
                  body: body,
                  sent_at: to_datetime(mail_dump["sent_at"]),
                  created_at: to_datetime(mail_dump["created_at"]),
                  updated_at: to_datetime(mail_dump["updated_at"]),
                  uuid: mail_dump["uuid"]
                }
                
                Couchtopostgres.MailDump.insert(mail_dump_changeset)
              _ ->
            end
          "Event" ->
            #event_changeset = %Couchtopostgres.Event{
            #  kind: mail_dump["event"],
            #  signature: mail_dump["signature"],
            #  mail_dump_id: Couchtopostgres.Event.mail_dump_id_from_mailgun_id(mail_dump["mailgun_id"])
            #  received_at: to_datetime(mail_dump["received_at"])
            #}
        end
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

end
