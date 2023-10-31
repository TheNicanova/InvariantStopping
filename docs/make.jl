using Documenter, InvariantStopping


makedocs(
  sitename="InvariantStopping.jl",
  modules=[InvariantStopping], 
  format=Documenter.HTML(),
  pages=[
    "Home" => "home.md",
    "Type" => "type.md",
    "Method" => "method.md",
    "Appendix: Docstring Guidelines" => "docstring_guidelines.md"
  ]
)
