defmodule Ash2385.MyDomain do
  use Ash.Domain,
    otp_app: :ash_2385

  resources do
    resource Ash2385.MyDomain.MyResource
  end
end
