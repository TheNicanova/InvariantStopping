using Documenter, InvariantStopping

makedocs(
  sitename="InvariantStopping.jl",
  modules=[InvariantStopping], 
  format=Documenter.HTML(),
  pages=[
    "Home" => "index.md",
    "Type" => "type.md",
    "Method" => "method.md",
    "Plotting" => "plot.md",
    "Appendix: Docstring Guidelines" => "docstring_guidelines.md"
  ]
)

deploydocs(
    repo = "github.com/TheNicanova/InvariantStopping.git",
    push_preview = true, # This can be set to false to only deploy on new tags or commits to main/master
    target = "build",
    branch = "gh-pages"
)
