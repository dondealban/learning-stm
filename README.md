# Structural Topic Modeling
This is a repository for my research using structural topic modeling, a method utilising machine learning techniques for automated content analysis of textual data.  

## What is a Structural Topic Model?
A Structural Topic Model is a general framework for topic modeling with document-level covariate information, which can improve inference and qualitative interpretability by affecting topical prevalence, topic content, or both [(Roberts et al. 2016)](#roberts_etal_2016). The goal of the Structural Topic Model is to allow researchers to discover topics and estimate their relationships to document metadata where the outputs of the models can be used for hypothesis testing of these relationships. The [`stm`](http://www.structuraltopicmodel.com) R package implements the estimation algorithms for the model and includes tools for every stage of a standard workflow including model estimation, summary, and visualisation.

## References

<a name="roberts_etal_2016"></a>
Roberts, M.E., Stewart, B.M. & Airoldi, E.M. (2016) A model of text for experimentation in the social sciences. *Journal of the American Statistical Association*, 111, 988–1003. [doi:10.1080/01621459.2016.1141684](http://dx.doi.org/10.1080/01621459.2016.1141684)