defmodule ExBanking.UsersSup do
  use DynamicSupervisor

  def start_link(_), do:
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def add_user(user) do
    case :ets.lookup(:users, user) do
      [] ->
        DynamicSupervisor.start_child(__MODULE__, {ExBanking.UserSrv, user})
      [_] ->
        {:error, :user_already_exists}
    end
  end

  @impl true
  def init(_) do
    :users = :ets.new(:users, [:named_table, :set, :public])
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
