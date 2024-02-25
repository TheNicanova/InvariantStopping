using Documenter, InvariantStopping

makedocs(
  sitename="InvariantStopping.jl",
  modules=[InvariantStopping], 
  format=Documenter.HTML(),
  pages=[
    "Usage" => "index.md",
    "Dev" => "dev.md",
    "Reference" =>"reference.md"
  ]
)

deploydocs(
    repo = "github.com/TheNicanova/InvariantStopping.git",
    push_preview = true, # This can be set to false to only deploy on new tags or commits to main/master
    target = "build",
    branch = "gh-pages"
)