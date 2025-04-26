defmodule Pls.Token do
  use Joken.Config,
    default_signer: :default_key

  # 1 hour
  def token_config, do: default_claims(default_exp: 60 * 60, aud: "pls")
end
