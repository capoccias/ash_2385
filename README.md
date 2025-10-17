# ash_2385

Reproduction for Issue in Ash: https://github.com/ash-project/ash/issues/2385

## Findings

I was initially unable to replicate the issue as the resource I created had only id and balance attributes.
Upon comparing the SQL in this app to my own I saw the difference was that my app also updated `updated_at`
Adding `timestamps(type: AshPostgres.TimestamptzUsec)` to the attributes block then reproduced the issue

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
00:36:27.191 [debug] QUERY ERROR source="my_resources" db=0.4ms queue=0.7ms idle=1851.3ms
UPDATE "my_resources" AS m0 SET "updated_at" = (CASE WHEN (CASE WHEN (m0."balance"::decimal + $1::decimal)::decimal < $2::decimal THEN ash_raise_error($3::jsonb, NULL::timestamptz(6)) ELSE (CASE WHEN (m0."balance"::decimal + $4::decimal)::decimal != m0."balance"::decimal THEN $5::timestamptz(6) ELSE m0."updated_at"::timestamptz(6) END)::timestamptz(6) END)::timestamptz(6) IS NULL THEN ash_raise_error($6::jsonb, NULL::timestamptz(6)) WHEN (m0."balance"::decimal + $7::decimal)::decimal < $8::decimal THEN ash_raise_error($9::jsonb, NULL::timestamptz(6)) ELSE (CASE WHEN (m0."balance"::decimal + $10::decimal)::decimal != m0."balance"::decimal THEN $11::timestamptz(6) ELSE m0."updated_at"::timestamptz(6) END)::timestamptz(6) END)::timestamptz(6), "balance" = (CASE WHEN (CASE WHEN (m0."balance"::decimal + $12::decimal)::decimal < $13::decimal THEN ash_raise_error($14::jsonb, NULL::decimal) ELSE m0."balance"::decimal + $15::decimal END)::decimal::decimal IS NULL THEN ash_raise_error($16::jsonb, NULL::decimal) ELSE (CASE WHEN (m0."balance"::decimal + $17::decimal)::decimal < $18::decimal THEN ash_raise_error($19::jsonb, NULL::decimal) ELSE m0."balance"::decimal + $20::decimal END)::decimal END)::decimal WHERE (m0."id"::uuid = $21::uuid) RETURNING m0."id", m0."balance", m0."inserted_at", m0."updated_at" [Decimal.new("-1"), Decimal.new("0"), "{\"input\":{\"message\":\"insufficient_balance\",\"fields\":[\"balance\"]},\"exception\":\"Ash.Error.Changes.InvalidChanges\"}", Decimal.new("-1"), ~U[2025-10-17 14:06:27.190221Z], "{\"input\":{\"type\":\"attribute\",\"resource\":\"Elixir.Ash2385.MyDomain.MyResource\",\"field\":\"updated_at\"},\"exception\":\"Ash.Error.Changes.Required\"}", Decimal.new("-1"), Decimal.new("0"), "{\"input\":{\"message\":\"insufficient_balance\",\"fields\":[\"balance\"]},\"exception\":\"Ash.Error.Changes.InvalidChanges\"}", Decimal.new("-1"), ~U[2025-10-17 14:06:27.190327Z], Decimal.new("-1"), Decimal.new("0"), "{\"input\":{\"message\":\"must be greater than or equal to %{min}\",\"vars\":{\"min\":\"0\"}},\"exception\":\"Ash.Error.Changes.InvalidChanges\"}", Decimal.new("-1"), "{\"input\":{\"type\":\"attribute\",\"resource\":\"Elixir.Ash2385.MyDomain.MyResource\",\"field\":\"balance\"},\"exception\":\"Ash.Error.Changes.Required\"}", Decimal.new("-1"), Decimal.new("0"), "{\"input\":{\"message\":\"must be greater than or equal to %{min}\",\"vars\":{\"min\":\"0\"}},\"exception\":\"Ash.Error.Changes.InvalidChanges\"}", Decimal.new("-1"), "0199f27e-3bf9-73f9-9f71-9a2327647ac6"]
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
00:39:13.774 [debug] QUERY ERROR source="my_resources" db=4.2ms queue=0.8ms idle=1289.6ms
UPDATE "my_resources" AS m0 SET "updated_at" = (CASE WHEN (m0."balance"::decimal + $1::decimal)::decimal != m0."balance"::decimal THEN $2::timestamptz(6) ELSE m0."updated_at"::timestamptz(6) END)::timestamptz(6), "balance" = (CASE WHEN (CASE WHEN (m0."balance"::decimal + $3::decimal)::decimal < $4::decimal THEN ash_raise_error($5::jsonb, NULL::decimal) ELSE m0."balance"::decimal + $6::decimal END)::decimal::decimal IS NULL THEN ash_raise_error($7::jsonb, NULL::decimal) ELSE (CASE WHEN (m0."balance"::decimal + $8::decimal)::decimal < $9::decimal THEN ash_raise_error($10::jsonb, NULL::decimal) ELSE m0."balance"::decimal + $11::decimal END)::decimal END)::decimal, "id" = (CASE WHEN (m0."balance"::decimal + $12::decimal)::decimal < $13::decimal THEN ash_raise_error($14::jsonb, NULL::uuid) ELSE m0."id"::uuid END)::uuid WHERE (m0."id"::uuid = $15::uuid) RETURNING m0."id", m0."balance", m0."inserted_at", m0."updated_at" [Decimal.new("-1"), ~U[2025-10-17 14:09:13.769037Z], Decimal.new("-1"), Decimal.new("0"), "{\"input\":{\"message\":\"must be greater than or equal to %{min}\",\"vars\":{\"min\":\"0\"}},\"exception\":\"Ash.Error.Changes.InvalidChanges\"}", Decimal.new("-1"), "{\"input\":{\"type\":\"attribute\",\"resource\":\"Elixir.Ash2385.MyDomain.MyResource\",\"field\":\"balance\"},\"exception\":\"Ash.Error.Changes.Required\"}", Decimal.new("-1"), Decimal.new("0"), "{\"input\":{\"message\":\"must be greater than or equal to %{min}\",\"vars\":{\"min\":\"0\"}},\"exception\":\"Ash.Error.Changes.InvalidChanges\"}", Decimal.new("-1"), Decimal.new("-1"), Decimal.new("0"), "{\"input\":{\"message\":\"insufficient_balance\",\"fields\":[\"balance\"]},\"exception\":\"Ash.Error.Changes.InvalidChanges\"}", "0199f280-9535-7f54-a170-824d94ff8976"]
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
