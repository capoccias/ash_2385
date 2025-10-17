# ash_2385

Reproduction for Issue in Ash: https://github.com/ash-project/ash/issues/2385

## Setup

```sh
mix archive.install hex igniter_new --force
mix igniter.new ash_2385 --install ash,ash_postgres --setup --yes

mix ash.gen.resource Ash2385.MyDomain.MyResource \
  --uuid-v7-primary-key id \
  --attribute balance:decimal:required:public \
  --domain Ash2385.MyDomain \
  --extend postgres

// Set balance to have default of 0

mix ash.codegen add_my_resources_table

// Add actions & validation
```

## Reproduction

`iex -S mix`

Ash 3.6.0+

```elixir
my_resource = Ash2385.MyDomain.MyResource.create!

Ash.Changeset.for_update(my_resource, :update_balance, %{amount: Decimal.new("-1")})
#Ash.Changeset<
  domain: Ash2385.MyDomain,
  action_type: :update,
  action: :update_balance,
  attributes: %{},
  atomics: [balance: balance + type(Decimal.new("-1"),  :decimal)],
  relationships: %{},
  arguments: %{amount: Decimal.new("-1")},
  errors: [
    %Ash.Error.Changes.InvalidChanges{
      fields: [:balance],
      message: "insufficient_balance",
      validation: nil,
      value: nil,
      splode: nil,
      bread_crumbs: [],
      vars: [],
      path: [],
      stacktrace: #Splode.Stacktrace<>,
      class: :invalid
    }
  ],
  data: %Ash2385.MyDomain.MyResource{
    id: "0199f27e-3bf9-73f9-9f71-9a2327647ac6",
    balance: Decimal.new("0.00000"),
    inserted_at: ~U[2025-10-17 14:06:23.227608Z],
    updated_at: ~U[2025-10-17 14:06:23.227608Z],
    __meta__: #Ecto.Schema.Metadata<:loaded, "my_resources">
  },
  valid?: false
>

my_resource |> Map.put(:balance, Decimal.new(1)) |> Ash.Changeset.for_update(:update_balance, %{amount: Decimal.new("-1")}) |> Ash.update()
{:error,
 %Ash.Error.Invalid{
   bread_crumbs: ["Returned from bulk query update: Ash2385.MyDomain.MyResource.update_balance"],
   changeset: "#Changeset<>",
   errors: [
     %Ash.Error.Changes.InvalidChanges{
       fields: nil,
       message: "must be greater than or equal to %{min}",
       validation: nil,
       value: nil,
       splode: Ash.Error,
       bread_crumbs: ["Returned from bulk query update: Ash2385.MyDomain.MyResource.update_balance"],
       vars: [{"min", "0"}],
       path: [],
       stacktrace: #Splode.Stacktrace<>,
       class: :invalid
     }
   ]
 }}
```

Ash 3.5.43

```elixir
my_resource =  Ash2385.MyDomain.MyResource.create!

Ash.Changeset.for_update(my_resource, :update_balance, %{amount: Decimal.new("-1")})
#Ash.Changeset<
  domain: Ash2385.MyDomain,
  action_type: :update,
  action: :update_balance,
  attributes: %{},
  atomics: [balance: balance + type(Decimal.new("-1"),  :decimal)],
  relationships: %{},
  arguments: %{amount: Decimal.new("-1")},
  errors: [
    %Ash.Error.Changes.InvalidChanges{
      fields: [:balance],
      message: "insufficient_balance",
      validation: nil,
      value: nil,
      splode: nil,
      bread_crumbs: [],
      vars: [],
      path: [],
      stacktrace: #Splode.Stacktrace<>,
      class: :invalid
    }
  ],
  data: %Ash2385.MyDomain.MyResource{
    id: "0199f280-9535-7f54-a170-824d94ff8976",
    balance: Decimal.new("0.00000"),
    inserted_at: ~U[2025-10-17 14:08:57.141984Z],
    updated_at: ~U[2025-10-17 14:08:57.141984Z],
    __meta__: #Ecto.Schema.Metadata<:loaded, "my_resources">
  },
  valid?: false
>

my_resource |> Map.put(:balance, Decimal.new(1)) |> Ash.Changeset.for_update(:update_balance, %{amount: Decimal.new("-1")}) |> Ash.update()
{:error,
 %Ash.Error.Invalid{
   bread_crumbs: ["Returned from bulk query update: Ash2385.MyDomain.MyResource.update_balance"],
   changeset: "#Changeset<>",
   errors: [
     %Ash.Error.Changes.InvalidChanges{
       fields: [:balance],
       message: "insufficient_balance",
       validation: nil,
       value: nil,
       splode: Ash.Error,
       bread_crumbs: ["Returned from bulk query update: Ash2385.MyDomain.MyResource.update_balance"],
       vars: [],
       path: [],
       stacktrace: #Splode.Stacktrace<>,
       class: :invalid
     }
   ]
 }
```
