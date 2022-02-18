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

  @spec deposit(ExBanking.user(), ExBanking.amount(), ExBanking.currency()) 
    :: {:ok, ExBanking.amount()} 
      | {:error, atom()}
  def deposit(user, amount, currency) do
    case  :ets.lookup(:users, user) do
      [] ->
        {:error, :user_does_not_exist}
      [{^user, pid, counter}] when counter <= 10 ->
        {:ok, GenServer.call(pid, {:deposit, currency, amount})}
      [{_user, _pid, _counter}] ->
        {:error, :too_many_requests_to_user}
    end
  end

  @spec get_balance(ExBanking.user(), ExBanking.currency()) 
    :: {:ok, ExBanking.amount()} 
      | {:error, atom()}
  def get_balance(user, currency) do
    case  :ets.lookup(:users, user) do
      [] ->
        {:error, :user_does_not_exist}
      [{^user, pid, counter}] when counter <= 10 ->
        {:ok, GenServer.call(pid, {:balance, currency})}
      [{_user, _pid, _counter}] ->
        {:error, :too_many_requests_to_user}
    end
  end

  @spec withdraw(ExBanking.user(), ExBanking.amount(), ExBanking.currency()) 
    :: {:ok, ExBanking.amount()} 
      | {:error, atom()}
  def withdraw(user, amount, currency) do
    case  :ets.lookup(:users, user) do
      [] ->
        {:error, :user_does_not_exist}
      [{^user, pid, counter}] when counter <= 10 ->
        GenServer.call(pid, {:withdraw, currency, amount})
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
  def handle_call({:deposit, currency, amount}, _from, %{balances: balances} = state) do
    balances = Map.update(balances, currency, amount, fn am -> Float.round(am + amount, 2) end)
    {:reply, Map.get(balances, currency, 0.0), %{state | balances: balances}}
  end

  def handle_call({:balance, currency}, _from, %{balances: balances} = state), do:
    {:reply, Map.get(balances, currency, 0.0), state}

  def handle_call({:withdraw, currency, amount}, _from, %{balances: balances} = state) do
    case Map.get(balances, currency, 0.0) do
      balance when balance >= amount ->
        balances = Map.update(balances, currency, amount, fn am -> Float.round(am - amount, 2) end)
        {:reply, {:ok, Map.get(balances, currency)}, %{state | balances: balances}}
      _ ->
        {:reply, {:error, :not_enough_money}, state}
    end
  end

  def handle_call(req, _from, state) do
    Logger.warn("Wrong call #{req} to #{__MODULE__} state #{inspect state}")
    {:reply, :error, state}
  end



end
