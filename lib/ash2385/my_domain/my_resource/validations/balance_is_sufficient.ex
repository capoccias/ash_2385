defmodule Ash2385.MyDomain.MyResource.Validations.BalanceIsSufficient do
  use Ash.Resource.Validation
  alias Ash.Error.Changes.InvalidChanges
  import Ash.Expr

  def validate(
        %{data: %{balance: balance}, arguments: %{amount: amount}},
        _opts,
        _context
      ) do
    case Decimal.compare(balance, Decimal.mult(-1, amount)) do
      :lt ->
        {:error,
         [
           fields: [:balance],
           message: "insufficient_balance"
         ]
         |> InvalidChanges.exception()}

      _ ->
        :ok
    end
  end

  def atomic(_changeset, _opts, _context) do
    {:atomic, [:balance], expr(^atomic_ref(:balance) + type(^arg(:amount), :decimal) < 0),
     expr(
       error(^InvalidChanges, %{
         fields: [:balance],
         message: "insufficient_balance"
       })
     )}
  end
end
