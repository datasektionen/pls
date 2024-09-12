[
  import_deps: [:ecto, :plug],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs,heex}"],
  subdirectories: ["priv/*/migrations"],
  locals_without_parens: []
]
