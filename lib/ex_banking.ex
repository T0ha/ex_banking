defmodule ExBanking do
  @moduledoc """
  Simple banking application
  """

  alias ExBanking.{UsersSup, UserSrv}

  @type user() :: String.t()
  @type currency() :: String.t()
  @type balance() :: float()
  @type amount() :: float()


  @doc """
  Function creates new user in the system
  with 0.0 balance for any currency
  """
  @spec create_user(user()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_binary(user) and user != "" do
    case UsersSup.add_user(user) do
      {:ok, _} ->
        :ok
      _ -> 
        {:error, :user_already_exists}
    end
  end
  def create_user(_), do: {:error, :wrong_arguments}

  @doc """
  Returns new_balance of the user in given format
  """
  @spec deposit(user(), amount(), currency()) :: {:ok, balance()} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit("", _amount, _currency), do: {:error, :wrong_arguments}
  def deposit(_user, _amount, ""), do: {:error, :wrong_arguments}
  def deposit(_user, amount, _currency) when amount <= 0.0, do:
    {:error, :wrong_arguments}
  def deposit(user, amount, currency) 
    when is_binary(user) 
      and is_binary(currency) 
      and is_float(amount) do
    UserSrv.deposit(user, amount, currency)
  end
  def deposit(_user, _amount, _currency), do: {:error, :wrong_arguments}


  @doc """
  Decreases user’s balance in given currency by amount value
  Returns new_balance of the user in given format
  """
  @spec withdraw(user(), amount(), currency()) :: {:ok, balance()} | {:error, :wrong_arguments | :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}
  def withdraw("", _amount, _currency), do: {:error, :wrong_arguments}
  def withdraw(_user, _amount, ""), do: {:error, :wrong_arguments}
  def withdraw(_user, amount, _currency) when amount <= 0.0, do:
    {:error, :wrong_arguments}
  def withdraw(user, amount, currency) 
    when is_binary(user) 
      and is_binary(currency) 
      and is_float(amount) do
    UserSrv.withdraw(user, amount, currency)
  end
  def withdraw(_user, _amount, _currency), do: {:error, :wrong_arguments}


  @doc """
  Returns balance of the user in given format
  """
  @spec get_balance(user(), currency()) :: {:ok, balance()} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance("", __currency), do: {:error, :wrong_arguments}
  def get_balance(_user, ""), do: {:error, :wrong_arguments}
    {:error, :wrong_arguments}
  def get_balance(user, currency) when is_binary(user) and is_binary(currency) do
    UserSrv.get_balance(user, currency)
  end
  def get_balance(_user, _currency), do: {:error, :wrong_arguments}


  @doc """
  """
  @spec send(user(), user(), amount(), currency()) :: {:ok, balance(), balance()} | {:error, :wrong_arguments | :not_enough_money | :sender_does_not_exist | :receiver_does_not_exist | :too_many_requests_to_sender | :too_many_requests_to_receiver}
  def send("", _to_user, _amount, _currency), do: {:error, :wrong_arguments}
  def send(_from_user, "", _amount, _currency), do: {:error, :wrong_arguments}

  def send(_from_user, _to_user, _amount, ""), do: {:error, :wrong_arguments}

  def send(_from_user, _to_user, amount, _currency) when amount <= 0.0, do:
    {:error, :wrong_arguments}
  def send(_from_user, _to_user, amount, _currency) when amount <= 0.0, do:
    {:error, :wrong_arguments}
  def send(from_user, to_user, amount, currency)
    when is_binary(from_user)
      and is_binary(to_user)
      and is_binary(currency)
      and is_float(amount) do
    with {:from, {:ok, from_balance}} <- {:from, UserSrv.withdraw(from_user, amount, currency)},
      {:to, {:ok, to_balance}} <- {:to, UserSrv.deposit(to_user, amount, currency)} do
      {:ok, from_balance, to_balance}
    else
      {:from, {:error, :user_does_not_exist}} -> {:error, :sender_does_not_exist}
      {:to, {:error, :user_does_not_exist}} -> 
        UserSrv.deposit(from_user, amount, currency)
        {:error, :receiver_does_not_exist}
      {:from, {:error, :too_many_requests_to_user}} -> {:error, :too_many_requests_to_sender}
      {:to, {:error, :too_many_requests_to_user}} ->
        UserSrv.deposit(from_user, amount, currency)
        {:error, :too_many_requests_to_receiver}
      {_, {:error, _} = err} -> err
    end
  end
  def send(_from_user, _to_user, _amount, _currency), do:
    {:error, :wrong_arguments}
end
