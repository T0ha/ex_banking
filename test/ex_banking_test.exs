defmodule ExBankingTest do
  use ExUnit.Case
  doctest ExBanking

  test "create new user works" do
    user = Faker.Internet.user_name() 
    assert ExBanking.create_user(user) == :ok
    user1 = Faker.Internet.user_name() 
    assert ExBanking.create_user(user1) == :ok
  end

  test "create 2 users with the same name returns error" do
    user = Faker.Internet.user_name() 
    assert ExBanking.create_user(user) == :ok
    assert ExBanking.create_user(user) == {:error, :user_already_exists}
  end

  test "create new user with wrong arguments returns error" do
    user = Faker.Random.Elixir.random_between(0, 100)
    assert ExBanking.create_user(user) == {:error, :wrong_arguments}
    assert ExBanking.create_user("") == {:error, :wrong_arguments}
  end

  test "deposit works" do
    user = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    amount1 = Faker.Commerce.price()
    currency = Faker.Currency.code() 
    currency1 = Faker.Currency.code() 
    total_amount = Float.round(amount + amount1, 2)

    assert ExBanking.create_user(user) == :ok

    assert ExBanking.deposit(user, amount, currency) == {:ok, amount}

    assert ExBanking.deposit(user, amount1, currency) == {:ok, total_amount}

    assert ExBanking.deposit(user, amount1, currency1) == {:ok, amount1}
  end

  test "deposit returns error for wrong arguments" do
    user = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    currency = Faker.Currency.code() 

    assert ExBanking.create_user(user) == :ok

    assert ExBanking.deposit(amount, amount, currency) == {:error, :wrong_arguments}

    assert ExBanking.deposit(user, currency, currency) == {:error, :wrong_arguments}
    assert ExBanking.deposit(user, amount, amount) == {:error, :wrong_arguments}
    assert ExBanking.deposit(user, -amount, currency) == {:error, :wrong_arguments}
    assert ExBanking.deposit(user, 0.0, currency) == {:error, :wrong_arguments}
    assert ExBanking.deposit("", amount, currency) == {:error, :wrong_arguments}
    assert ExBanking.deposit(user, amount, "") == {:error, :wrong_arguments}
  end

  test "deposit returns error for non exising user" do
    user = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    currency = Faker.Currency.code() 

    assert ExBanking.deposit(user, amount, currency) == {:error, :user_does_not_exist}
  end

  test "withdraw works" do
    user = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    amount1 = Faker.Commerce.price()
    currency = Faker.Currency.code() 
    currency1 = Faker.Currency.code() 
    total_amount = Float.round(amount + amount1, 2)

    assert ExBanking.create_user(user) == :ok
    assert ExBanking.deposit(user, total_amount, currency) == {:ok, total_amount}
    assert ExBanking.deposit(user, total_amount, currency1) == {:ok, total_amount}

    assert ExBanking.withdraw(user, amount, currency) == {:ok, amount1}

    assert ExBanking.withdraw(user, amount1, currency) == {:ok, 0.0}

    assert ExBanking.withdraw(user, amount1, currency1) == {:ok, amount}
  end

  test "withdraw returns error for wrong arguments" do
    user = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    amount1 = Faker.Commerce.price()
    currency = Faker.Currency.code() 
    total_amount = Float.round(amount + amount1, 2)

    assert ExBanking.create_user(user) == :ok
    assert ExBanking.deposit(user, total_amount, currency) == {:ok, total_amount}

    assert ExBanking.withdraw(amount, amount, currency) == {:error, :wrong_arguments}

    assert ExBanking.withdraw(user, currency, currency) == {:error, :wrong_arguments}
    assert ExBanking.withdraw(user, amount, amount) == {:error, :wrong_arguments}
    assert ExBanking.withdraw(user, -amount, currency) == {:error, :wrong_arguments}
    assert ExBanking.withdraw(user, 0.0, currency) == {:error, :wrong_arguments}
    assert ExBanking.withdraw("", amount, currency) == {:error, :wrong_arguments}
    assert ExBanking.withdraw(user, amount, "") == {:error, :wrong_arguments}
  end

  test "withdraw returns error for non exising user" do
    user = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    currency = Faker.Currency.code() 

    assert ExBanking.withdraw(user, amount, currency) == {:error, :user_does_not_exist}
  end

  test "withdraw returns error for not enough money" do
    user = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    amount1 = Faker.Commerce.price()
    currency = Faker.Currency.code() 

    assert ExBanking.create_user(user) == :ok
    assert ExBanking.deposit(user, amount, currency) == {:ok, amount}

    assert ExBanking.withdraw(user, amount + amount1, currency) == {:error, :not_enough_money}
  end

  test "get_balance works" do
    user = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    amount1 = Faker.Commerce.price()
    currency = Faker.Currency.code() 
    currency1 = Faker.Currency.code() 
    total_amount = Float.round(amount + amount1, 2)

    assert currency != currency1
    assert ExBanking.create_user(user) == :ok
    assert ExBanking.deposit(user, total_amount, currency) == {:ok, total_amount}
    assert ExBanking.deposit(user, amount, currency1) == {:ok, amount}

    assert ExBanking.get_balance(user, currency) == {:ok, total_amount}


    assert ExBanking.get_balance(user, currency1) == {:ok, amount}
  end

  test "get_balance returns error for wrong arguments" do
    user = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    amount1 = Faker.Commerce.price()
    currency = Faker.Currency.code() 
    total_amount = Float.round(amount + amount1, 2)

    assert ExBanking.create_user(user) == :ok
    assert ExBanking.deposit(user, total_amount, currency) == {:ok, total_amount}

    assert ExBanking.get_balance(amount, currency) == {:error, :wrong_arguments}

    assert ExBanking.get_balance(user, amount) == {:error, :wrong_arguments}
    assert ExBanking.get_balance("", currency) == {:error, :wrong_arguments}
    assert ExBanking.get_balance(user, "") == {:error, :wrong_arguments}
  end

  test "get_balance returns error for non exising user" do
    user = Faker.Internet.user_name() 
    currency = Faker.Currency.code() 

    assert ExBanking.get_balance(user, currency) == {:error, :user_does_not_exist}
  end

  test "send works" do
    user = Faker.Internet.user_name() 
    user1 = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    amount1 = Faker.Commerce.price()
    currency = Faker.Currency.code() 
    total_amount = Float.round(amount + amount1, 2)

    assert ExBanking.create_user(user) == :ok
    assert ExBanking.create_user(user1) == :ok

    assert ExBanking.deposit(user, total_amount, currency) == {:ok, total_amount}
    assert ExBanking.deposit(user1, amount1, currency) == {:ok, amount1}

    assert ExBanking.send(user, user1, amount, currency) == {:ok, amount1, total_amount}

    assert ExBanking.send(user, user1, amount1, currency) == {:ok, 0.0, Float.round(2 * amount1 + amount, 2)}

    assert ExBanking.send(user1, user, amount1, currency) == {:ok, total_amount, amount1}
  end

  test "send returns error for wrong arguments" do
    user = Faker.Internet.user_name() 
    user1 = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    amount1 = Faker.Commerce.price()
    currency = Faker.Currency.code() 
    total_amount = Float.round(amount + amount1, 2)

    assert ExBanking.create_user(user) == :ok
    assert ExBanking.create_user(user1) == :ok

    assert ExBanking.deposit(user, total_amount, currency) == {:ok, total_amount}
    assert ExBanking.deposit(user1, total_amount, currency) == {:ok, total_amount}

    assert ExBanking.send(amount, user1, amount, currency) == {:error, :wrong_arguments}
    assert ExBanking.send(user, amount, amount, currency) == {:error, :wrong_arguments}

    assert ExBanking.send(user, user1, currency, currency) == {:error, :wrong_arguments}
    assert ExBanking.send(user, user1, amount, amount) == {:error, :wrong_arguments}
    assert ExBanking.send(user, user1, -amount, currency) == {:error, :wrong_arguments}
    assert ExBanking.send(user, user1, 0.0, currency) == {:error, :wrong_arguments}

    assert ExBanking.send("", user1, amount, currency) == {:error, :wrong_arguments}
    assert ExBanking.send(user, "", amount, currency) == {:error, :wrong_arguments}
    assert ExBanking.send(user, user1, amount, "") == {:error, :wrong_arguments}
  end

  test "send returns error for non exising user" do
    user = Faker.Internet.user_name() 
    user1 = Faker.Internet.user_name() 
    amount = Faker.Commerce.price()
    currency = Faker.Currency.code() 

    assert ExBanking.send(user, user1, amount, currency) == {:error, :sender_does_not_exist}

    assert ExBanking.create_user(user) == :ok
    assert ExBanking.deposit(user, amount, currency) == {:ok, amount}

    assert ExBanking.send(user, user1, amount, currency) == {:error, :receiver_does_not_exist}
  end
end
