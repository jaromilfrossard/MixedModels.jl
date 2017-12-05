using Weave

weavit(fnm::AbstractString) =
weave(joinpath("jmd", fnm), doctype="github", plotlib="Gadfly", fig_path="./assets/", fig_ext=".svg", out_path="./src/")

#weavit("constructors.jmd")
#weavit("extractors.jmd")
#weavit("bootstrap.jmd")
#weavit("SimpleLMM.jmd")
#weavit("MultipleTerms.jmd")
#weavit("nAGQ.jmd")
weavit("SingularCovariance.jmd")
#weavit("SubjectItem.jmd")