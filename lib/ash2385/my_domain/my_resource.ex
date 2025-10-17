defmodule Ash2385.MyDomain.MyResource do
  use Ash.Resource,
    otp_app: :ash_2385,
    domain: Ash2385.MyDomain,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "my_resources"
    repo Ash2385.Repo
  end

  code_interface do
    define :create
  end

  actions do
    defaults [:read, create: :*]

    update :update_balance do
      require_atomic? true

      argument :amount, :decimal, allow_nil?: false

      validate {Ash2385.MyDomain.MyResource.Validations.BalanceIsSufficient, []},
        where: [compare(:amount, less_than: Decimal.new(0))]

      change atomic_update(:balance, expr(balance + type(^arg(:amount), :decimal)))
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :balance, :decimal do
      default 0
      constraints min: 0
      allow_nil? false
      public? true
    end

    timestamps(type: AshPostgres.TimestamptzUsec)
  end
end
