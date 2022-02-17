defmodule ExBanking.UserSrv do
  use GenServer
  require Logger

  def child_spec(user) do
    %{id: user,
      start: {__MODULE__, :start_link, [user]}
    }
  end

  def start_link(user) do
    GenServer.start_link(__MODULE__, [user])
  end

  @spec get_balance(ExBanking.user(), ExBanking.currency()) 
    :: {:ok, ExBanking.amount()} 
      | {:error, atom()}
  def get_balance(user, currency) do
    case  :ets.lookup(:users, user) do
      [] ->
        {:error, :user_does_not_exist}
      [{^user, pid, counter}] when counter <= 10 ->
          GenServer.call(pid, {:balance, currency})
      [{_user, _pid, _counter}] ->
        {:error, :too_many_requests_to_user}
    end
  end

  @impl true
  def init([user]) do
    :ets.insert(:users, {user, self(), 0})
    {:ok, %{
      balances: %{},
      name: user
    }}
  end

  @impl true
  def handle_call({:balance, currency}, _from, %{balances: balances} = state), do:
    {:reply, Map.get(balances, currency, 0.0), state}

  def handle_call(req, _from, state) do
    Logger.warn("Wrong call #{req} to #{__MODULE__} state #{inspect state}")
    {:reply, :error, state}
  end



end
