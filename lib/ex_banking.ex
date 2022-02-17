defmodule ExBanking do
  @moduledoc """
  Simple banking application
  """

  @type user() :: String.t()
  @type currency() :: String.t()
  @type balance() :: float()
  @type amount() :: float()


  @doc """
  Function creates new user in the system
  with 0.0 balance for any currency
  """
  @spec create_user(user()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user), do: :ok

  @doc """
  Returns new_balance of the user in given format
  """
  @spec deposit(user(), amount(), currency()) :: {:ok, balance()} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def deposit(user, amount, currency) do
    {:ok, amount}
  end


  @doc """
  Decreases user’s balance in given currency by amount value
  Returns new_balance of the user in given format
  """
  @spec withdraw(user(), amount(), currency()) :: {:ok, balance()} | {:error, :wrong_arguments | :user_does_not_exist | :not_enough_money | :too_many_requests_to_user}
  def withdraw(user, amount, currency) do
    {:ok, amount}
  end


  @doc """
  Returns balance of the user in given format
  """
  @spec get_balance(user(), currency()) :: {:ok, balance()} | {:error, :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user}
  def get_balance(user, currency) do
    {:ok, 0.0}
  end


  @doc """
  """
  @spec send(user(), user(), amount(), currency()) :: {:ok, balance(), balance()} | {:error, :wrong_arguments | :not_enough_money | :sender_does_not_exist | :receiver_does_not_exist | :too_many_requests_to_sender | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency) do
    {:ok, 0.0, amount}
  end
end
