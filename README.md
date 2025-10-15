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
    id: "0199e706-bd54-7e0a-8468-11259b32a0d8",
    balance: Decimal.new("0"),
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
    id: "0199e705-4d02-7ab7-8015-b9ed0a22b18a",
    balance: Decimal.new("0"),
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
 }}
```
