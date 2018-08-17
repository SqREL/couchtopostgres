defmodule Couchtopostgres do
  use Application

  def start(_, _) do
    Couchtopostgres.DbSupervisor.start_link
    Couchtopostgres.ImportSupervisor.start_link

    Couchtopostgres.ImportWorker.run

    { :ok, self }
  end

end
