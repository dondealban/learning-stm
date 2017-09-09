# Structural Topic Modeling
This is a repository for my research using structural topic modeling, a method utilising machine learning techniques for automated content analysis of textual data.  

## What is a Structural Topic Model?
A Structural Topic Model is a general framework for topic modeling with document-level covariate information, which can improve inference and qualitative interpretability by affecting topical prevalence, topic content, or both [(Roberts et al. 2016)](#roberts_etal_2016). The goal of the Structural Topic Model is to allow researchers to discover topics and estimate their relationships to document metadata where the outputs of the models can be used for hypothesis testing of these relationships. The [`stm`](http://www.structuraltopicmodel.com) R package implements the estimation algorithms for the model and includes tools for every stage of a standard workflow including model estimation, summary, and visualisation.

## Projects
Below is a list that describes my research projects using structural topic modeling:

### 0. Test Project
This is technically not my own research project but my first exercise to learn and understand structural topic modeling using the `stm` R package [(Roberts et al. 2017a)](#roberts_etal_2017a). I followed the instructions from the `stm` package [vignette](https://github.com/bstewart/stm/blob/master/inst/doc/stmVignette.pdf?raw=true), which contains a short technical overview of structural topic models, and a demonstration of the basic usage of the package through examples of the functions used in a typical workflow. I copied the datasets used in the vignette in the test project folder of this repository for eaasy replication. The original links to the example datasets can be found in the vignette. Also, I used the scripts from Nick B. Adams' [D-Lab Text Analysis Working Group](https://github.com/nickbadams/D-Lab_TextAnalysisWorkingGroup) with some minor modifications for this learning exercise.

## References

<a name="roberts_etal_2016"></a>
Roberts, M.E., Stewart, B.M. & Airoldi, E.M. (2016) A model of text for experimentation in the social sciences. *Journal of the American Statistical Association*, 111, 988–1003. [doi:10.1080/01621459.2016.1141684](http://dx.doi.org/10.1080/01621459.2016.1141684)

<a name="roberts_etal_2017a"></a>
Roberts, M.E., Stewart, B.M. Tingley, D. & Benoit, K. (2017a) stm: Estimation of the Structural Topic Model. [(https://cran.r-project.org/web/packages/stm/index.html)](https://cran.r-project.org/web/packages/stm/index.html)